#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")
CONTAINER_NAME=${PROJECT_NAME}-bats-1
# version
docker exec -i ${CONTAINER_NAME} bats -v
# unit testing
docker exec -i ${CONTAINER_NAME} bats /tmp/tests.bat
# function, external file run, setup and teardown test
docker exec -i ${CONTAINER_NAME} bats /tmp/test2.bat