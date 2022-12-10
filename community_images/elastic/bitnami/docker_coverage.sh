#!/bin/bash

set -x
set -e

# shellcheck disable=SC1091
SCRIPTPATH="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/coverage.sh

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")
NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")

echo "Json params for docker coverage = $JSON"

ES_SERVER="127.0.0.1"
# run coverage script
test_elasticsearch "${ES_SERVER}" "yes" "${NAMESPACE}"
