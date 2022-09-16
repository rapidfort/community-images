#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

NETWORK_NAME=$(jq -r '.network_name' < "$JSON_PARAMS")
CONTAINER_NAME=$(jq -r '.container_details.curl.name' < "$JSON_PARAMS")

# run test on docker container
docker exec \
    -i "$CONTAINER_NAME" \
    curl --version
