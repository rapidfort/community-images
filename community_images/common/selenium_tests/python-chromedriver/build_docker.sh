#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
RAPIDFORT_ACCOUNT="${RAPIDFORT_ACCOUNT:-rapidfort}"

TAG=$(curl -s "https://hub.docker.com/v2/namespaces/schukinpavel/repositories/python-chromedriver/tags" | jq -r '.results[0].name')

IMAGE_TAG="$RAPIDFORT_ACCOUNT"/python-chromedriver:"${TAG}"

docker build -t "${IMAGE_TAG}" "${SCRIPTPATH}"
docker push "${IMAGE_TAG}"
docker tag "${IMAGE_TAG}" "$RAPIDFORT_ACCOUNT"/python-chromedriver:latest
docker push "$RAPIDFORT_ACCOUNT"/python-chromedriver:latest
