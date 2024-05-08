#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

sleep 30

# Get JWT token for sign-in
JWT=$(kubectl get secret/console-sa-secret -n ${NAMESPACE} -o json | jq -r ".data.token" | base64 -d)
OPERATOR_PORT='9090'

# Port forward for minio operator console
kubectl port-forward svc/console -n ${NAMESPACE} --address 0.0.0.0 9090:9090 &
PORT_FORWARD_PID=$!

# Run selenium tests
"${SCRIPTPATH}"/../../common/selenium_tests/runner-dc.sh "${NAMESPACE} ${JWT}" "${OPERATOR_PORT}" "${SCRIPTPATH}"/selenium_tests 2>&1

# Gracefully stop port-forwarding
kill -s 15 "${PORT_FORWARD_PID}"
