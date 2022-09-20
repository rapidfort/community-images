#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker coverage = $JSON"

CONTAINER_NAME=$(jq -r '.container_details.consul.name' < "$JSON_PARAMS")

docker exec -i "${CONTAINER_NAME}" ls 