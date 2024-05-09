#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

RAPIDFORT_ACCOUNT="${RAPIDFORT_ACCOUNT:-rapidfort}"
NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")

# get docker host ip
REDIS_HOST=$(jq -r '.container_details."redis-official".ip_address' < "$JSON_PARAMS")
REDIS_CONTAINER= $(jq -r '.container_details."redis-official".name' < "$JSON_PARAMS")
# REPO_PATH=$(jq -r '.image_tag_details."redis-official".repo_path' < "$JSON_PARAMS")
# TAG=$(jq -r '.image_tag_details."redis-official".tag' < "$JSON_PARAMS")

# run redis-client tests
docker exec -it "${REDIS_CONTAINER}" redis-benchmark -h "${REDIS_HOST}" -p 6379 -n 1000 -c 10
