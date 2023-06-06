#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")

CONTAINER1_NAME="${PROJECT_NAME}"-etcd1-1

# exec into container and run coverage script
docker exec -i "${CONTAINER1_NAME}" bash -c /tmp/coverage_script.sh