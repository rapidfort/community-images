#!/bin/bash

set -x

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
    docker run -it --rm=true --name transformers-pytorch-cpu-${TAG} --cap-add=SYS_PTRACE -v "$(pwd)"/src:/app --workdir=/app ${IMAGE_REPOSITORY}:${TAG} python3 sample.py
    # sleep for 30 min
    echo "waiting for 30 sec"
    sleep 30s
}

build_images ${INPUT_REGISTRY} ${INPUT_ACCOUNT} ${REPOSITORY} ${BASE_TAG} test
