#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")
CONTAINER_NAME=${PROJECT_NAME}-prometheus-1

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/coverage.sh
PROMETHEUS_PORT='9090'
PROMETHEUS_HOST='localhost'

# publishing metrices
test_prometheus "${CONTAINER_NAME}" "${PROMETHEUS_HOST}" "${PROMETHEUS_PORT}"

# ui testing
"${SCRIPTPATH}"/../../common/selenium_tests/runner-dc.sh "${PROMETHEUS_HOST}" "${PROMETHEUS_PORT}" "${SCRIPTPATH}"/selenium_tests 2>&1

FLASK_CONTAINER_NAME="flaskapp"
# cleanup
docker stop "${FLASK_CONTAINER_NAME}"
docker rm "${FLASK_CONTAINER_NAME}"