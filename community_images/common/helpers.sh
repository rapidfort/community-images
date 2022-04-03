#!/bin/bash

set -x
set -e

DOCKERHUB_REGISTRY=docker.io
RAPIDFORT_ACCOUNT=rapidfort
NAMESPACE=ci-dev
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

create_stub()
{
    local INPUT_REGISTRY=$1
    local INPUT_ACCOUNT=$2
    local REPOSITORY=$3
    local TAG=$4

    local INPUT_IMAGE_FULL=${INPUT_REGISTRY}/${INPUT_ACCOUNT}/${REPOSITORY}:${TAG}
    local STUB_IMAGE_FULL=${DOCKERHUB_REGISTRY}/${RAPIDFORT_ACCOUNT}/${REPOSITORY}-rfstub:${TAG}

    # Pull docker image
    docker pull ${INPUT_IMAGE_FULL}
    
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

    local INPUT_IMAGE_FULL=${INPUT_REGISTRY}/${INPUT_ACCOUNT}/${REPOSITORY}:${TAG}
    local OUTPUT_IMAGE_FULL=${DOCKERHUB_REGISTRY}/${RAPIDFORT_ACCOUNT}/${REPOSITORY}:${TAG}
    
    # Create stub for docker image
    rfharden ${INPUT_IMAGE_FULL}-rfstub

    # Change tag to point to rapidfort docker account
    docker tag ${INPUT_IMAGE_FULL}-rfhardened ${OUTPUT_IMAGE_FULL}

    # Push stub to our dockerhub account
    docker push ${OUTPUT_IMAGE_FULL}

    echo "Hardened images pushed to ${OUTPUT_IMAGE_FULL}" 
}

build_images()
{
    local INPUT_REGISTRY=$1
    local INPUT_ACCOUNT=$2
    local REPOSITORY=$3
    local BASE_TAG=$4
    local TEST_FUNCTION=$5

    local TAG=$(${SCRIPTPATH}/../../common/dockertags ${INPUT_ACCOUNT}/${REPOSITORY} ${BASE_TAG})

    echo "Running image generation for ${INPUT_ACCOUNT}/${REPOSITORY} ${TAG}"

    create_stub ${INPUT_REGISTRY} ${INPUT_ACCOUNT} ${REPOSITORY} ${TAG}
    ${TEST_FUNCTION} ${RAPIDFORT_ACCOUNT}/${REPOSITORY}-rfstub ${TAG}
    harden_image ${INPUT_REGISTRY} ${INPUT_ACCOUNT} ${REPOSITORY} ${TAG}
    ${TEST_FUNCTION} ${RAPIDFORT_ACCOUNT}/${REPOSITORY} ${TAG}

    echo "Completed image generation for ${INPUT_ACCOUNT}/${REPOSITORY} ${TAG}"
}