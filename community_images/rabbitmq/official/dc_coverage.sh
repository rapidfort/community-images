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
PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")

# Container name for rabbitmq
CONTAINER_NAME="${PROJECT_NAME}"-rabbitmq-1

RABBITMQ_PASS=password
# run coverage script
test_rabbitmq "${NAMESPACE}" "${CONTAINER_NAME}" "${RABBITMQ_PASS}"
