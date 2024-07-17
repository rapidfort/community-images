#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")
CONTAINER_NAME=${PROJECT_NAME}-minio-1

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

MINIO_HOST='127.0.0.1'
MINIO_PORT='9001'
# version
docker exec -i "${CONTAINER_NAME}" minio -v
docker exec -i "${CONTAINER_NAME}" minio

("${SCRIPTPATH}"/../../common/selenium_tests/runner-dc.sh "${MINIO_HOST}" "${MINIO_PORT}" "${SCRIPTPATH}"/selenium_tests 2>&1) 2>&1
