#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for k8s coverage = $JSON"

SCRIPTPATH=$(jq -r '.image_script_dir' < "$JSON_PARAMS")
NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")
RELEASE_NAME=$(jq -r '.release_name' < "$JSON_PARAMS")

AIRFLOW_SERVER="${RELEASE_NAME}"."${NAMESPACE}".svc.cluster.local
AIRFLOW_PORT='8080'

"${SCRIPTPATH}"/../../../common/selenium_tests/runner.sh "${AIRFLOW_SERVER}" "${AIRFLOW_PORT}" "${SCRIPTPATH}"/selenium_tests "${NAMESPACE}" 2>&1
