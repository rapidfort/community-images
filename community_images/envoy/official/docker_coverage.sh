#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker coverage = $JSON"

NETWORK_NAME=$(jq -r '.network_name' < "$JSON_PARAMS")
ENVOY_HOST=$(jq -r '.container_details."envoy-official".ip_address' < "$JSON_PARAMS")

# run test on docker container
docker run --rm --network="${NETWORK_NAME}" \
    -i alpine \
    apk add curl;curl http://"${ENVOY_HOST}":8082/ip;curl http://"${ENVOY_HOST}":9901/ready
