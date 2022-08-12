#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"
NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")

CONTAINER_NAME="${NAMESPACE}"-redis-primary-1
REDIS_PASSWORD=my_password

# run redis tests
docker exec -i "${CONTAINER_NAME}" bash -c "cat /tmp/test.redis | redis-cli"

# run redis coverage
docker exec -i "${CONTAINER_NAME}" bash -c "/tmp/redis_coverage.sh"

# run redis benchmark
docker exec -i "${CONTAINER_NAME}" bash -c redis-benchmark -h localhost -p 6379 -a "$REDIS_PASSWORD" -n 1000 -c 10
