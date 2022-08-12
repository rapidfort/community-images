#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

RAPIDFORT_ACCOUNT="${RAPIDFORT_ACCOUNT:-rapidfort}"
IMAGE_REPOSITORY="$RAPIDFORT_ACCOUNT"/redis6-ib
NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")

# get docker host ip
REDIS_HOST=$(jq -r '.container_details.redis6.ip_address' < "$JSON_PARAMS")

# run redis-client tests
docker run --rm -i --network="${NAMESPACE}" \
    "${IMAGE_REPOSITORY}":latest \
    redis-benchmark -h "${REDIS_HOST}" -p 6379 -n 1000 -c 10
