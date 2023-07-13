#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

AIRFLOW_CONTAINER=${PROJECT_NAME}-airflow-ib-1

# Add a user for web app
docker exec ${AIRFLOW_CONTAINER} airflow users create --role Admin --username rf-test --password rf_password123! --email rf-test@nomail.com --firstname rf --lastname test

AIRFLOW_PORT='8080'
"${SCRIPTPATH}"/../../../common/selenium_tests/runner-dc.sh "localhost" "${AIRFLOW_PORT}" "${SCRIPTPATH}"/selenium_tests 2>&1

# pytest "${SCRIPTPATH}"/selenium_tests/test_enablealldags.py --server "localhost" --port "$AIRFLOW_PORT"