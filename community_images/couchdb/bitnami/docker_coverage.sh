#!/bin/bash

set -x
set -e

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/coverage.sh

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker coverage = $JSON"

# NETWORK_NAME=$(jq -r '.network_name' < "$JSON_PARAMS")
# ENVOY_HOST=$(jq -r '.container_details.envoy.ip_address' < "$JSON_PARAMS")
test_couchdb