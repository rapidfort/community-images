#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
RAPIDFORT_ACCOUNT="${RAPIDFORT_ACCOUNT:-rapidfort}"

TAG=$(git ls-remote https://github.com/idealo/mongodb-performance-test.git HEAD | awk '{ print $1}')

IMAGE_TAG="$RAPIDFORT_ACCOUNT"/mongodb-perfomance-test:"${TAG}"

docker build -t "${IMAGE_TAG}" "${SCRIPTPATH}"
docker push "${IMAGE_TAG}"
docker tag "${IMAGE_TAG}" "$RAPIDFORT_ACCOUNT"/mongodb-perfomance-test:latest
docker push "$RAPIDFORT_ACCOUNT"/mongodb-perfomance-test:latest
