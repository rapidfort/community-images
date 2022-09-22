#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/scripts/bash_helper.sh

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")
RELEASE_NAME=$(jq -r '.release_name' < "$JSON_PARAMS")

CONTAINER_NAME="${PROJECT_NAME}"-redis-node-0
REDIS_PASSWORD=bitnami

docker exec -i "$CONTAINER_NAME" \
    ${REDIS_PASSWORD} ${RELEASE_NAME} /tmp/test.redis

docker exec -i "$CONTAINER_NAME" \
    redis-benchmark -h "${RELEASE_NAME}" -c 2 -n 100 -a "$REDIS_PASSWORD" --cluster
