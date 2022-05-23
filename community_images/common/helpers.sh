#!/bin/bash

set -x
set -e

DOCKERHUB_REGISTRY=docker.io
RAPIDFORT_ACCOUNT=rapidfort
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
NAMESPACE_TO_CLEANUP=

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
    INPUT_TAG=$1 # example: 10.6.8-debian-10-r2
    IS_LATEST_TAG=$2

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
        docker tag "${INPUT_TAG}" "$rolling_tag"
        docker push "$rolling_tag"
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
    rfharden "${INPUT_IMAGE_FULL}"-rfstub

    if [[ "${PUBLISH_IMAGE}" = "yes" ]]; then

        # Change tag to point to rapidfort docker account
        docker tag "${INPUT_IMAGE_FULL}"-rfhardened "${OUTPUT_IMAGE_FULL}"

        # Push stub to our dockerhub account
        docker push "${OUTPUT_IMAGE_FULL}"

        add_rolling_tags "${OUTPUT_IMAGE_FULL}" "${IS_LATEST_TAG}"

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
    TAG=$("${SCRIPTPATH}"/../../common/dockertags "${INPUT_ACCOUNT}"/"${REPOSITORY}" "${BASE_TAG}")

    if [[ "${PUBLISH_IMAGE}" = "yes" ]]; then
        # dont create image for publish mode if tag exists
        RAPIDFORT_TAG=$("${SCRIPTPATH}"/../../common/dockertags "${RAPIDFORT_ACCOUNT}"/"${REPOSITORY}" "${BASE_TAG}")

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
    local INPUT_ACCOUNT=$2
    local REPOSITORY=$3
    local BASE_TAG_ARRAY=$4
    local TEST_FUNCTION=$5
    local PUBLISH_IMAGE=$6

    for index in "${!BASE_TAG_ARRAY[@]}"; do
        tag="${BASE_TAG_ARRAY[$index]}"
        IS_LATEST_TAG="no"
        if [[ "$index" = 0 ]]; then
            IS_LATEST_TAG="yes"
        fi
        build_image "${INPUT_REGISTRY}" "${INPUT_ACCOUNT}" "${REPOSITORY}" "${tag}" test "${PUBLISH_IMAGE}" "${IS_LATEST_TAG}"
    done
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
}
trap finish EXIT