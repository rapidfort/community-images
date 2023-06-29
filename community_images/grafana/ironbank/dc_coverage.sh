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

PORT=3000

# Initiating Selenium tests
"${SCRIPTPATH}"/../../common/selenium_tests/runner-dc.sh "dummy_arg" "${PORT}" "${SCRIPTPATH}"/selenium_tests 2>&1

echo "Grafana cli coverage"
GRAFANA_CONTAINER=${PROJECT_NAME}-grafana-ib-1
docker exec -it ${GRAFANA_CONTAINER} grafana cli -h

# Restart to setup and load plugins installed.
docker restart ${GRAFANA_CONTAINER}
sleep 30
