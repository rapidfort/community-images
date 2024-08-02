#!/bin/bash

set -ex

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/scripts/bash_helper.sh

JSON_PARAMS="$1"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")
CONTAINER_NAME="${PROJECT_NAME}"-keycloak-1

# Wait
sleep 10

# log for debugging
docker inspect "${CONTAINER_NAME}"

# find non-tls and tls port
docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Ports.\"8080/tcp\"[0].HostPort"
PORT=$(docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Ports.\"8080/tcp\"[0].HostPort")

# Initiating Selenium tests
echo "Running Selenium tests"
("${SCRIPTPATH}"/../../common/selenium_tests/runner-dc.sh \
    "${PROJECT_NAME}" "${PORT}" "${SCRIPTPATH}"/selenium_tests 2>&1) >&2
