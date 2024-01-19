#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")
CONTAINER_NAME=${PROJECT_NAME}-webserver-1

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

MOODLE_HOST=$(docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Networks.\"${PROJECT_NAME}_internal\".IPAddress")
MOODLE_PORT='8080'

"${SCRIPTPATH}"/../../common/selenium_tests/runner-dc.sh "${MOODLE_HOST}" "${MOODLE_PORT}" "${SCRIPTPATH}"/selenium_tests 2>&1
