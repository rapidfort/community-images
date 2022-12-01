#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/scripts/bash_helper.sh

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")
CONTAINER_NAME="${PROJECT_NAME}"-yourls-1

# Wait for all mysql server to set up
sleep 60

# log for debugging
docker inspect "${CONTAINER_NAME}"

# find non-tls and tls port
docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Ports.\"80/tcp\"[0].HostPort"
PORT=$(docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Ports.\"80/tcp\"[0].HostPort")

# Initiating Selenium tests
"${SCRIPTPATH}"/../../common/selenium_tests/runner-dc.sh "${PROJECT_NAME}" "${PORT}" "${SCRIPTPATH}"/selenium_tests 2>&1
