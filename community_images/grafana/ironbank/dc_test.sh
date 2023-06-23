#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# # shellcheck disable=SC1091
# . "${SCRIPTPATH}"/../../common/scripts/bash_helper.sh

# JSON_PARAMS="$1"

# JSON=$(cat "$JSON_PARAMS")

# echo "Json params for docker compose coverage = $JSON"

# PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")


# Clean startup
docker-compose down
docker-compose up -d

PROJECT_NAME=ironbank
PROMETHEUS_CONTAINER=${PROJECT_NAME}-prometheus-1

PORT=3000
PROMETHEUS_SERVER=$(docker inspect "${PROMETHEUS_CONTAINER}" | jq -r ".[].NetworkSettings.Networks.${PROJECT_NAME}_default.IPAddress")

# Initiating Selenium tests
"${SCRIPTPATH}"/../../common/selenium_tests/runner-dc.sh "${PROMETHEUS_SERVER}" "${PORT}" "${SCRIPTPATH}"/selenium_tests 2>&1
