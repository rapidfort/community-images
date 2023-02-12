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

# wait for the zookeeper ensemble to come online
sleep 60

CONTAINER_NAME="${RELEASE_NAME}-0"
# copy over the script to the pod
kubectl cp "${SCRIPTPATH}"/scripts/zookeeper_coverage_script.sh "${CONTAINER_NAME}":/opt/bitnami/scripts/coverage_script.sh -n "${NAMESPACE}"

test_zookeeper "${CONTAINER_NAME}" "${NAMESPACE}" "yes"
