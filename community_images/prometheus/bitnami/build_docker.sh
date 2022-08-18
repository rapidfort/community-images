#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
RAPIDFORT_ACCOUNT="${RAPIDFORT_ACCOUNT:-rapidfort}"

TAG="latest"

IMAGE_TAG="$RAPIDFORT_ACCOUNT"/flaskapp:"${TAG}"

docker build -t "${IMAGE_TAG}" "${SCRIPTPATH}"
docker push "${IMAGE_TAG}"
