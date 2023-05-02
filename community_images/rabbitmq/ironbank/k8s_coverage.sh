#!/bin/bash

set -x
set -e

# shellcheck disable=SC1091
SCRIPTPATH="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/coverage.sh

JSON_PARAMS="$1"

NAMESPACE=$(jq -r '.namespace_name' <"$JSON_PARAMS")
RELEASE_NAME=$(jq -r '.release_name' <"$JSON_PARAMS")

RABBITMQ_SERVER="${RELEASE_NAME}"."${NAMESPACE}".svc.cluster.local

RABBITMQ_PASS=$(kubectl get secret --namespace "${NAMESPACE}" "${RELEASE_NAME}" -o jsonpath="{.data.rabbitmq-password}" | base64 -d)
# run coverage script
test_rabbitmq "${NAMESPACE}" "${RABBITMQ_SERVER}" "${RABBITMQ_PASS}"
