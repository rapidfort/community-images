#!/bin/bash

set -x

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <tag>"
    exit 1
fi

TAG=$1 #4.9.1
echo "Running image generation for $0 $1"

IREGISTRY=docker.io
IREPO=huggingface/transformers-pytorch-cpu
OREPO=rapidfort/transformers-pytorch-cpu-rfstub
PUB_REPO=rapidfort/transformers-pytorch-cpu


create_stub()
{
    # Pull docker image
    docker pull ${IREGISTRY}/${IREPO}:${TAG}

    # Create stub for docker image
    rfstub ${IREGISTRY}/${IREPO}:${TAG}

    # Change tag to point to rapidfort docker account
    docker tag ${IREGISTRY}/${IREPO}:${TAG}-rfstub ${OREPO}:${TAG}

    # Push stub to our dockerhub account
    docker push ${OREPO}:${TAG}
}


test()
{
    echo "Testing hugging face transformers-pytorch-cpu"
    docker run -it --rm=true --name transformers-pytorch-cpu-${TAG} --cap-add=SYS_PTRACE -v "$(pwd)"/src:/app --workdir=/app ${OREPO}:${TAG} python3 sample.py
    # sleep for 30 min
    echo "waiting for 30 sec"
    sleep 30s

    # kill docker container
    docker kill transformers-pytorch-cpu-${TAG}
}

harden_image()
{
    # Create stub for docker image
    rfharden ${IREGISTRY}/${IREPO}:${TAG}-rfstub

    # Change tag to point to rapidfort docker account
    docker tag ${IREGISTRY}/${IREPO}:${TAG}-rfhardened ${PUB_REPO}:${TAG}

    # Push stub to our dockerhub account
    docker push ${PUB_REPO}:${TAG}

    echo "Hardened images pushed to ${PUB_REPO}:${TAG}" 
}


main()
{
    create_stub
    test
    harden_image
}

main
