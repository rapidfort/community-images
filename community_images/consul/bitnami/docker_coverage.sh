#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker coverage = $JSON"

NETWORK_NAME=$(jq -r '.network_name' < "$JSON_PARAMS")
CONSUL_HOST=$(jq -r '.container_details.consul.ip_address' < "$JSON_PARAMS")

