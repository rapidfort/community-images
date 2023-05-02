#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

# shellcheck disable=SC1091
SCRIPTPATH="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/coverage.sh

JSON_PARAMS="$1"

NAMESPACE=$(jq -r '.namespace_name' <"$JSON_PARAMS")
RELEASE_NAME=$(jq -r '.release_name' <"$JSON_PARAMS")

RABBITMQ_PASS=password
# run coverage script
test_rabbitmq "${NAMESPACE}" rabbitmq_server "${RABBITMQ_PASS}"