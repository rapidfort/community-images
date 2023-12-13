#!/bin/bash

set -x
set -e

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/scripts/bash_helper.sh


JSON_PARAMS="$1"

#JSON=$(cat "$JSON_PARAMS")

NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")
RELEASE_NAME=$(jq -r '.release_name' < "$JSON_PARAMS")
echo "NAMESPACE: $NAMESPACE"
echo "RELEASE_NAME: $RELEASE_NAME"

sleep 10
CONTAINER_NAME=$(kubectl get pods -n "$NAMESPACE" -l "app.kubernetes.io/instance=$RELEASE_NAME" -o jsonpath='{.items[0].metadata.name}')
# copy over the script to the pod
kubectl cp "${SCRIPTPATH}"/config/fluent-bit.config "${CONTAINER_NAME}":/tmp/fluent-bit.config -n "${NAMESPACE}"
sleep 10
kubectl cp "${SCRIPTPATH}"/scripts/fluent-bit_coverage_script.sh "${CONTAINER_NAME}":/tmp/fluent-bit_cvoverage_script.sh -n "${NAMESPACE}"

