#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")
CONTAINER_NAME=${PROJECT_NAME}-podman-1
# version
docker exec -i "${CONTAINER_NAME}" podman --version
docker exec -i "${CONTAINER_NAME}" command -v podman
# testing all commands
docker exec -i "${CONTAINER_NAME}" /tmp/coverage.sh