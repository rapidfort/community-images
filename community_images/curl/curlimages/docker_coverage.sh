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

# use entrypoint
docker exec \
    -i "$CONTAINER_NAME" \
    entrypoint.sh --version

# run curl
docker exec \
    -i "$CONTAINER_NAME" \
    curl -L -v https://curl.haxx.se

# run post call
docker exec \
    -i "$CONTAINER_NAME" \
    curl -d@/work/test.txt https://httpbin.org/post

# run http2
docker exec \
    -i "$CONTAINER_NAME" \
    curl -sI https://curl.se -o/dev/null -w '%{http_version}\n'

# test brotli compression
docker exec \
    -i "$CONTAINER_NAME" \
    curl --compressed https://httpbin.org/brotli
