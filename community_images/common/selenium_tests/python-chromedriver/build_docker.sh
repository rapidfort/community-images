#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
RAPIDFORT_ACCOUNT="${RAPIDFORT_ACCOUNT:-rapidfort}"

TAG=$(git ls-remote https://github.com/joyzoursky/docker-python-chromedriver.git HEAD | awk '{ print $1}')

IMAGE_TAG="$RAPIDFORT_ACCOUNT"/python-chromedriver:"${TAG}"

docker build -t "${IMAGE_TAG}" "${SCRIPTPATH}"
docker push "${IMAGE_TAG}"
docker tag "${IMAGE_TAG}" "$RAPIDFORT_ACCOUNT"/python-chromedriver:latest
docker push "$RAPIDFORT_ACCOUNT"/python-chromedriver:latest
