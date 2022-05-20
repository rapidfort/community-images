#!/bin/bash

set -x
set -e

DOCKERHUB_REGISTRY=docker.io
RAPIDFORT_ACCOUNT=rapidfort
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

create_stub()
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
    rfstub ${INPUT_IMAGE_FULL}

    # Change tag to point to rapidfort docker account
    docker tag ${INPUT_IMAGE_FULL}-rfstub ${STUB_IMAGE_FULL}

    # Push stub to our dockerhub account
    docker push ${STUB_IMAGE_FULL}
}

harden_image()
{
    local INPUT_REGISTRY=$1
    local INPUT_ACCOUNT=$2
    local REPOSITORY=$3
    local TAG=$4
    local PUBLISH_IMAGE=$5

    local INPUT_IMAGE_FULL=${INPUT_REGISTRY}/${INPUT_ACCOUNT}/${REPOSITORY}:${TAG}
    local OUTPUT_IMAGE_FULL=${DOCKERHUB_REGISTRY}/${RAPIDFORT_ACCOUNT}/${REPOSITORY}:${TAG}
    local OUTPUT_IMAGE_LATEST_FULL=${DOCKERHUB_REGISTRY}/${RAPIDFORT_ACCOUNT}/${REPOSITORY}:latest
    
    # Create stub for docker image
    rfharden ${INPUT_IMAGE_FULL}-rfstub

    if [[ "${PUBLISH_IMAGE}" = "yes" ]]; then

        # Change tag to point to rapidfort docker account
        docker tag ${INPUT_IMAGE_FULL}-rfhardened ${OUTPUT_IMAGE_FULL}

        # Push stub to our dockerhub account
        docker push ${OUTPUT_IMAGE_FULL}

        # create latest tag
        docker tag ${OUTPUT_IMAGE_FULL} ${OUTPUT_IMAGE_LATEST_FULL}

        # Push latest tag
        docker push ${OUTPUT_IMAGE_LATEST_FULL}

        echo "Hardened images pushed to ${OUTPUT_IMAGE_FULL}" 
    else
        echo "Non publish mode"
    fi
}

get_namespace_string()
{
    local REPOSITORY=$1
    echo "${REPOSITORY}-`echo $RANDOM | md5sum | head -c 10; echo;`"
}

setup_namespace()
{
    local NAMESPACE=$1
    kubectl create namespace ${NAMESPACE}

    # add rapidfortbot credentials
    kubectl --namespace ${NAMESPACE} create secret generic rf-regcred --from-file=.dockerconfigjson=/home/ubuntu/.docker/config.json --type=kubernetes.io/dockerconfigjson

    # add tls certs
    kubectl apply -f ${SCRIPTPATH}/../../common/cert_managet_ns.yml --namespace ${NAMESPACE} 
}

cleanup_namespace()
{
    local NAMESPACE=$1
    kubectl delete namespace ${NAMESPACE}
}


build_images()
{
    local INPUT_REGISTRY=$1
    local INPUT_ACCOUNT=$2
    local REPOSITORY=$3
    local BASE_TAG=$4
    local TEST_FUNCTION=$5
    local PUBLISH_IMAGE=$6

    local TAG=$(${SCRIPTPATH}/../../common/dockertags ${INPUT_ACCOUNT}/${REPOSITORY} ${BASE_TAG})
    local NAMESPACE=$(get_namespace_string ${REPOSITORY})

    echo "Running image generation for ${INPUT_ACCOUNT}/${REPOSITORY} ${TAG}"
    setup_namespace ${NAMESPACE}

    create_stub ${INPUT_REGISTRY} ${INPUT_ACCOUNT} ${REPOSITORY} ${TAG}
    ${TEST_FUNCTION} ${RAPIDFORT_ACCOUNT}/${REPOSITORY} ${TAG}-rfstub ${NAMESPACE}
    harden_image ${INPUT_REGISTRY} ${INPUT_ACCOUNT} ${REPOSITORY} ${TAG} ${PUBLISH_IMAGE}

    if [[ "${PUBLISH_IMAGE}" = "yes" ]]; then
        ${TEST_FUNCTION} ${RAPIDFORT_ACCOUNT}/${REPOSITORY} ${TAG} ${NAMESPACE}
    else
        echo "Non publish mode, cant test image as image not published"
    fi

    bash -c "${SCRIPTPATH}/../../common/delete_tag.sh ${REPOSITORY} ${TAG}-rfstub"
    cleanup_namespace ${NAMESPACE}

    echo "Completed image generation for ${INPUT_ACCOUNT}/${REPOSITORY} ${TAG}"
}