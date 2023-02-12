#!/bin/bash

set -x
set -e

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/coverage.sh

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")
PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")
# Container name for consul-node1
CONTAINER_NAME="${PROJECT_NAME}"-zookeeper1-1

test_zookeeper "${CONTAINER_NAME}" "${NAMESPACE}" "no"
