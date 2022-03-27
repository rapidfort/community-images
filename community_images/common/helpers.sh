#!/bin/bash

set -x

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <tag>"
    exit 1
fi

TAG=$1 #4.9.1
echo "Running image generation for $0 $1"

# IREGISTRY=docker.io
# IREPO=huggingface/transformers-pytorch-cpu
# OREPO=rapidfort/transformers-pytorch-cpu-rfstub
# PUB_REPO=rapidfort/transformers-pytorch-cpu

# INPUT_REGISTRY=docker.io
DOCKERHUB_REGISTRY=docker.io
RAPIDFORT_ACCOUNT=rapidfort
NAMESPACE=ci-dev

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
    local REPOSITORY=$1
    local TAG=$2

    local STUB_IMAGE_FULL=${DOCKERHUB_REGISTRY}/${RAPIDFORT_ACCOUNT}/${REPOSITORY}-rfstub:${TAG}
    local HARDENED_IMAGE_FULL=${DOCKERHUB_REGISTRY}/${RAPIDFORT_ACCOUNT}/${REPOSITORY}:${TAG}-rfhardened
    local OUTPUT_IMAGE_FULL=${DOCKERHUB_REGISTRY}/${RAPIDFORT_ACCOUNT}/${REPOSITORY}:${TAG}
    
    # Create stub for docker image
    rfharden ${STUB_IMAGE_FULL}

    # Change tag to point to rapidfort docker account
    docker tag ${HARDENED_IMAGE_FULL} ${OUTPUT_IMAGE_FULL}

    # Push stub to our dockerhub account
    docker push ${OUTPUT_IMAGE_FULL}

    echo "Hardened images pushed to ${OUTPUT_IMAGE_FULL}" 
}

build_images()
{
    local INPUT_REGISTRY=$1
    local INPUT_ACCOUNT=$2
    local REPOSITORY=$3
    local TAG=$4

    create_stub ${INPUT_REGISTRY} ${INPUT_ACCOUNT} ${REPOSITORY} ${TAG}
    test ${RAPIDFORT_ACCOUNT}/${REPOSITORY}-rfstub
    harden_image ${REPOSITORY} ${TAG}
    test ${RAPIDFORT_ACCOUNT}/${REPOSITORY}
}