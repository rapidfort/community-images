#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
. ${SCRIPTPATH}/../../common/helpers.sh


BASE_TAG=4.9.
INPUT_REGISTRY=docker.io
INPUT_ACCOUNT=huggingface
REPOSITORY=transformers-pytorch-cpu

test()
{
    local IMAGE_REPOSITORY=$1
    local TAG=$2

    echo "Testing hugging face transformers-pytorch-cpu"
    docker run -i --rm=true --name transformers-pytorch-cpu-${TAG} --cap-add=SYS_PTRACE -v ${SCRIPTPATH}/src:/app --workdir=/app ${IMAGE_REPOSITORY}:${TAG} python3 sample.py
}

build_images ${INPUT_REGISTRY} ${INPUT_ACCOUNT} ${REPOSITORY} ${BASE_TAG} test
