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
PORT=8080
CONTAINER_NAME="${PROJECT_NAME}"-ghost-1

# exec into container and run coverage script
docker exec -i "${CONTAINER_NAME}" cat /opt/bitnami/ghost/config.production.json

# log for debugging
docker inspect "${CONTAINER_NAME}"

# Running selenium tests
"${SCRIPTPATH}"/../../common/selenium_tests/runner-dc.sh "${PROJECT_NAME}" "${PORT}" "${SCRIPTPATH}"/selenium_tests 2>&1
