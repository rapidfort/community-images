#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

WORDPRESS_PORT='8080'
("${SCRIPTPATH}"/../../common/selenium_tests/runner-dc.sh "${PROJECT_NAME}" "${WORDPRESS_PORT}" "${SCRIPTPATH}"/selenium_tests 2>&1) 2>&1
