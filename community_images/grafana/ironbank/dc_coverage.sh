#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/scripts/bash_helper.sh

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

# PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")

# Wait for setup
sleep 30

PORT=3000

# Initiating Selenium tests
"${SCRIPTPATH}"/../../common/selenium_tests/runner-dc.sh "${PROJECT_NAME}" "${PORT}" "${SCRIPTPATH}"/selenium_tests 2>&1
