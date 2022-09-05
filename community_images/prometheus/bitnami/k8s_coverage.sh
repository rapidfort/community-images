#!/bin/bash

set -x
set -e

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/coverage.sh

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for k8s coverage = $JSON"

NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")
RELEASE_NAME=$(jq -r '.release_name' < "$JSON_PARAMS")

# get pod name
PROMETHEUS_SERVER=$(kubectl get pod "${RELEASE_NAME}" -n "${NAMESPACE}" --template '{{.status.podIP}}')

PROMETHEUS_PORT=9090

test_prometheus "${NAMESPACE}" "${PROMETHEUS_SERVER}" "${PROMETHEUS_PORT}"
