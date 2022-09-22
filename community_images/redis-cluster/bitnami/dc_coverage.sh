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

CONTAINER_NAME="${PROJECT_NAME}"-redis-node-0-1
REDIS_PASSWORD=bitnami

# run all redis commands in test.redis
docker exec -i "$CONTAINER_NAME" \
    bash -c "/tmp/redis_cluster_runner.sh ${REDIS_PASSWORD} localhost 6379 /tmp/test.redis"

# run redis coverage
docker exec -i "$CONTAINER_NAME" \
    bash -c "/tmp/redis_coverage.sh"

# run redis benchmark
docker exec -i "$CONTAINER_NAME"  bash -c "redis-benchmark -h localhost -p 6379 -c 2 -n 100 -a ${REDIS_PASSWORD} --cluster"
