#!/bin/bash

set -x
set -e

DOCKERHUB_REGISTRY=docker.io
RAPIDFORT_ACCOUNT=rapidfort
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
NAMESPACE_TO_CLEANUP=
declare -A PULL_COUNTER

function create_stub()
{
    local INPUT_REGISTRY=$1
    local INPUT_ACCOUNT=$2
    local REPOSITORY=$3
    local TAG=$4

    local INPUT_IMAGE_FULL=${INPUT_REGISTRY}/${INPUT_ACCOUNT}/${REPOSITORY}:${TAG}
    local STUB_IMAGE_FULL=${DOCKERHUB_REGISTRY}/${RAPIDFORT_ACCOUNT}/${REPOSITORY}:${TAG}-rfstub

    # Pull docker image
    docker pull "${INPUT_IMAGE_FULL}"
    
    # Create stub for docker image
    rfstub "${INPUT_IMAGE_FULL}"

    # Change tag to point to rapidfort docker account
    docker tag "${INPUT_IMAGE_FULL}"-rfstub "${STUB_IMAGE_FULL}"

    # Push stub to our dockerhub account
    docker push "${STUB_IMAGE_FULL}"
}

function add_rolling_tags()
{
    REPOSITORY=$1
    INPUT_TAG=$2 # example: 10.6.8-debian-10-r2
    IS_LATEST_TAG=$3

    IFS='-'
    # shellcheck disable=SC2162
    read -a input_arr <<< "$INPUT_TAG"

    version="${input_arr[0]}"
    os="${input_arr[1]}"
    os_ver="${input_arr[2]}"

    IFS="."
    # shellcheck disable=SC2162
    read -a ver_arr <<< "$version"
    maj_v="${ver_arr[0]}"
    min_v="${ver_arr[1]}"

    FULL_VER_TAG="$version" # 10.6.8
    VER_OS_TAG="$maj_v"."$min_v"-"$os"-"$os_ver" # 10.6-debian-10
    MAJ_MINOR_TAG="$maj_v"."$min_v" # 10.6

    declare -a rolling_tags=("$FULL_VER_TAG" "$VER_OS_TAG" "$MAJ_MINOR_TAG")

    if [[ "$IS_LATEST_TAG" = "yes" ]]; then
        rolling_tags+=("latest")
    fi

    for rolling_tag in "${rolling_tags[@]}"; do
        docker tag "${REPOSITORY}:${INPUT_TAG}" "${REPOSITORY}:$rolling_tag"
        docker push "${REPOSITORY}:$rolling_tag"
    done
}

function harden_image()
{
    local INPUT_REGISTRY=$1
    local INPUT_ACCOUNT=$2
    local REPOSITORY=$3
    local TAG=$4
    local PUBLISH_IMAGE=$5
    local IS_LATEST_TAG=$6

    local INPUT_IMAGE_FULL=${INPUT_REGISTRY}/${INPUT_ACCOUNT}/${REPOSITORY}:${TAG}
    local OUTPUT_IMAGE_FULL=${DOCKERHUB_REGISTRY}/${RAPIDFORT_ACCOUNT}/${REPOSITORY}:${TAG}
    
    # Create stub for docker image
    if [[ -f "${SCRIPTPATH}"/.rfignore ]]; then
        rfharden "${INPUT_IMAGE_FULL}"-rfstub -p "${SCRIPTPATH}"/.rfignore
    else
        rfharden "${INPUT_IMAGE_FULL}"-rfstub
    fi

    if [[ "${PUBLISH_IMAGE}" = "yes" ]]; then

        # Change tag to point to rapidfort docker account
        docker tag "${INPUT_IMAGE_FULL}"-rfhardened "${OUTPUT_IMAGE_FULL}"

        # Push stub to our dockerhub account
        docker push "${OUTPUT_IMAGE_FULL}"

        add_rolling_tags "${DOCKERHUB_REGISTRY}/${RAPIDFORT_ACCOUNT}/${REPOSITORY}" "${TAG}" "${IS_LATEST_TAG}"

        echo "Hardened images pushed to ${OUTPUT_IMAGE_FULL}" 
    else
        echo "Non publish mode"
    fi
}

function get_namespace_string()
{
    local REPOSITORY=$1
    echo "${REPOSITORY}-$(echo $RANDOM | md5sum | head -c 10; echo;)"
}

function setup_namespace()
{
    local NAMESPACE=$1
    kubectl create namespace "${NAMESPACE}"

    # add rapidfortbot credentials
    kubectl --namespace "${NAMESPACE}" create secret generic rf-regcred --from-file=.dockerconfigjson="${HOME}"/.docker/config.json --type=kubernetes.io/dockerconfigjson

    # add tls certs
    kubectl apply -f "${SCRIPTPATH}"/../../common/cert_managet_ns.yml --namespace "${NAMESPACE}" 
}

function cleanup_namespace()
{
    local NAMESPACE=$1
    kubectl delete namespace "${NAMESPACE}"
}


function build_image()
{
    local INPUT_REGISTRY=$1
    local INPUT_ACCOUNT=$2
    local REPOSITORY=$3
    local BASE_TAG=$4
    local TEST_FUNCTION=$5
    local PUBLISH_IMAGE=$6
    local IS_LATEST_TAG=$7

    local TAG RAPIDFORT_TAG NAMESPACE
    TAG=$("${SCRIPTPATH}"/../../common/dockertags.sh "${INPUT_ACCOUNT}"/"${REPOSITORY}" "${BASE_TAG}")

    if [[ "${PUBLISH_IMAGE}" = "yes" ]]; then
        # dont create image for publish mode if tag exists
        RAPIDFORT_TAG=$("${SCRIPTPATH}"/../../common/dockertags.sh "${RAPIDFORT_ACCOUNT}"/"${REPOSITORY}" "${BASE_TAG}")

        if [[ "${TAG}" = "${RAPIDFORT_TAG}" ]]; then
            echo "Rapidfort image exists:${RAPIDFORT_TAG}, aborting run"
            return
        fi
    fi

    NAMESPACE=$(get_namespace_string "${REPOSITORY}")
    NAMESPACE_TO_CLEANUP="${NAMESPACE}"
    echo "Running image generation for ${INPUT_ACCOUNT}/${REPOSITORY} ${TAG}"
    setup_namespace "${NAMESPACE}"

    create_stub "${INPUT_REGISTRY}" "${INPUT_ACCOUNT}" "${REPOSITORY}" "${TAG}"
    "${TEST_FUNCTION}" "${RAPIDFORT_ACCOUNT}"/"${REPOSITORY}" "${TAG}"-rfstub "${NAMESPACE}"
    harden_image "${INPUT_REGISTRY}" "${INPUT_ACCOUNT}" "${REPOSITORY}" "${TAG}" "${PUBLISH_IMAGE}" "${IS_LATEST_TAG}"

    if [[ "${PUBLISH_IMAGE}" = "yes" ]]; then
        "${TEST_FUNCTION}" "${RAPIDFORT_ACCOUNT}"/"${REPOSITORY}" "${TAG}" "${NAMESPACE}"
    else
        echo "Non publish mode, cant test image as image not published"
    fi

    bash -c "${SCRIPTPATH}/../../common/delete_tag.sh ${REPOSITORY} ${TAG}-rfstub"
    cleanup_namespace "${NAMESPACE}"
    NAMESPACE_TO_CLEANUP=
    echo "Completed image generation for ${INPUT_ACCOUNT}/${REPOSITORY} ${TAG}"
}

function build_images()
{
    local INPUT_REGISTRY=$1
    shift
    local INPUT_ACCOUNT=$1
    shift
    local REPOSITORY=$1
    shift
    local TEST_FUNCTION=$1
    shift
    local PUBLISH_IMAGE=$1
    shift
    local BASE_TAG_ARRAY=( "$@" )

    for index in "${!BASE_TAG_ARRAY[@]}"; do
        tag="${BASE_TAG_ARRAY[$index]}"
        IS_LATEST_TAG="no"
        if [[ "$index" = 0 ]]; then
            IS_LATEST_TAG="yes"
        fi
        build_image "${INPUT_REGISTRY}" "${INPUT_ACCOUNT}" "${REPOSITORY}" "${tag}" test "${PUBLISH_IMAGE}" "${IS_LATEST_TAG}"
    done
}

# Retries a command a with backoff.
#
# The retry count is given by ATTEMPTS (default 10), the
# initial backoff timeout is given by TIMEOUT in seconds
# (default 5.)
#
# Successive backoffs double the timeout.
#
# Beware of set -e killing your whole script!
function with_backoff {
  local max_attempts="${ATTEMPTS-9}"
  local timeout="${TIMEOUT-5}"
  local attempt=0
  local exitCode=0

  while [[ "$attempt" < "$max_attempts" ]]
  do
    set +e
    "$@"
    exitCode="$?"
    set -e

    if [[ "$exitCode" == 0 ]]
    then
      break
    fi

    echo "Failure! Retrying in $timeout.." 1>&2
    sleep "$timeout"
    attempt=$(( attempt + 1 ))
    timeout=$(( timeout * 2 ))
  done

  if [[ "$exitCode" != 0 ]]
  then
    echo "You've failed me for the last time! ($*)" 1>&2
  fi

  return "$exitCode"
}

function cleanup_certs()
{
    rm -rf "${SCRIPTPATH}"/certs
    mkdir -p "${SCRIPTPATH}"/certs
}

function create_certs()
{
    cleanup_certs

    openssl req -newkey rsa:4096 \
                -x509 \
                -sha256 \
                -days 3650 \
                -nodes \
                -out "${SCRIPTPATH}"/certs/server.crt \
                -keyout "${SCRIPTPATH}"/certs/server.key \
                -subj "/C=SI/ST=Ljubljana/L=Ljubljana/O=Security/OU=IT Department/CN=www.example.com"
}

function report_pulls()
{
    local REPO_NAME="${1}"
    local PULL_COUNT=${2-1} # default to single pull count
    echo "docker pull counter: $REPO_NAME $PULL_COUNT"
    if [ -z "${PULL_COUNTER[$REPO_NAME]}" ]; then
        PULL_COUNTER["$REPO_NAME"]=0
    fi
    echo "docker pull count previous value:" ${PULL_COUNTER[$REPO_NAME]}

    # shellcheck disable=SC2004
    PULL_COUNTER["$REPO_NAME"]=$((PULL_COUNTER[$REPO_NAME]+"$PULL_COUNT"))
    echo "docker pull count updated to:" ${PULL_COUNTER[$REPO_NAME]}
}

function finish {
    if [[ -z "$NAMESPACE_TO_CLEANUP" ]]; then
        kubectl get pods --all-namespaces
        kubectl get services --all-namespaces
    else
        kubectl -n "${NAMESPACE_TO_CLEANUP}" get pods
        kubectl -n "${NAMESPACE_TO_CLEANUP}" delete all --all
        kubectl delete namespace "${NAMESPACE_TO_CLEANUP}"
    fi

    JSON_STR="{"
    FIRST=1
    for key in "${!PULL_COUNTER[@]}"; do
        if [ "$FIRST" = "0" ] ; then JSON_STR+=", " ; fi
        JSON_STR+="\"$key\":${PULL_COUNTER[$key]}"
        FIRST=0
    done
    JSON_STR+="}"

    # curl -X POST \
    #     -H "Accept: application/json" \
    #     -H "Authorization: Bearer ${PULL_COUNTER_MAGIC_TOKEN}" \
    #     -d ${JSON_STR} https://data-receiver.rapidfort.io/counts/internal_image_pulls
}
trap finish EXIT
