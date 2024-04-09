#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")
CONTAINER_NAME=${PROJECT_NAME}-kibana-1

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

KIBANA_HOST=$(docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Networks.\"${PROJECT_NAME}_elastic\".IPAddress")
KIBANA_PORT='5601'
sleep 20
curl -XGET "http://"${KIBANA_HOST}":5601/api/status" | jq .

"${SCRIPTPATH}"/../../common/selenium_tests/runner-dc.sh "${KIBANA_HOST}" "${KIBANA_PORT}" "${SCRIPTPATH}"/selenium_tests 2>&1
