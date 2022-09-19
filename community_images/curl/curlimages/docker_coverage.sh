#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

CONTAINER_NAME=$(jq -r '.container_details.curl.name' < "$JSON_PARAMS")

# run version
docker exec \
    -i "$CONTAINER_NAME" \
    curl --version

# run curl
docker exec \
    -i "$CONTAINER_NAME" \
    curl -L -v https://curl.haxx.se

# run post call
docker exec \
    -i "$CONTAINER_NAME" \
    curl -d@/work/test.txt https://httpbin.org/post
