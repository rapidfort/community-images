#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

CONTAINER_NAME="$(jq -r '.project_name' < "$JSON_PARAMS")-chart-test-1"

sleep 10

docker exec -it "${CONTAINER_NAME}" bash -c "ct version"

docker exec -it "${CONTAINER_NAME}" bash -c "ct --target-branch main list-changed"

# Linting issues are there in https://github.com/helm/examples.git so exit code is not 0
docker exec -it "${CONTAINER_NAME}" bash -c "ct --target-branch main lint" || true
docker exec -it "${CONTAINER_NAME}" bash -c "ct --target-branch main install"

docker exec -it "${CONTAINER_NAME}" bash -c "ct completion > /dev/null"

rm -r "${SCRIPTPATH}/examples"
