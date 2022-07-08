#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

TAG=$(git ls-remote https://github.com/influxdata/inch.git HEAD | awk '{ print $1}')

IMAGE_TAG=rapidfort/influxdb-inch-test:"${TAG}"

docker build -t "${IMAGE_TAG}" "${SCRIPTPATH}"
docker push "${IMAGE_TAG}"
docker tag "${IMAGE_TAG}" rapidfort/influxdb-inch-test:latest
docker push rapidfort/influxdb-inch-test:latest
