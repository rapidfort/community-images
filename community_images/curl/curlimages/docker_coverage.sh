#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

NETWORK_NAME=$(jq -r '.network_name' < "$JSON_PARAMS")
CONTAINER_NAME=$(jq -r '.container_details.curl' < "$JSON_PARAMS")

# run test on docker container
docker run --rm --network="${NETWORK_NAME}" \
    -i alpine \
    apk add curl;curl http://"${ENVOY_HOST}":8081/ip;curl http://"${ENVOY_HOST}":9001/ready
