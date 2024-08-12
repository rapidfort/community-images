#!/bin/bash

set -x
set -e
# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/scripts/bash_helper.sh

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")
CONTAINER_NAME="${PROJECT_NAME}"-metabase-1

sleep 10

METABASE_HOST=$(docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Networks.\"${PROJECT_NAME}_internal\".IPAddress")
METABASE_PORT='3000'

# request to the Metabase setup endpoint
curl http://localhost:3000/setup/
# endpoint called after setup
curl http://localhost:3000/api/session/properties

# ui-testing
("${SCRIPTPATH}"/../../common/selenium_tests/runner-dc.sh "${METABASE_HOST}" "${METABASE_PORT}" "${SCRIPTPATH}"/selenium_tests 2>&1) >&2
