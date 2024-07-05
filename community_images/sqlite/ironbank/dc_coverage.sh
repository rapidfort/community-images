#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")

CONTAINER_NAME="${PROJECT_NAME}"-sqlite3-1
# version
docker exec -i "${CONTAINER_NAME}" sqlite3 --version
# testing sqlite commands
docker exec -i "${CONTAINER_NAME}" sh -c 'sqlite3 < /tmp/test.sql'
