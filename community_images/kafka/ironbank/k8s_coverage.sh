#!/bin/bash

set -x
set -e

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for k8s coverage = $JSON"

NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")
RELEASE_NAME=$(jq -r '.release_name' < "$JSON_PARAMS")

sleep 60

CONTAINER_NAME="${RELEASE_NAME}"
# copy over the script to the pod
kubectl cp "${SCRIPTPATH}"/scripts/zookeeper_coverage_script.sh "${CONTAINER_NAME}":/tmp/coverage_script.sh -n "${NAMESPACE}"

kubectl exec -i ${CONTAINER_NAME} -n ${NAMESPACE} -- bash /tmp/coverage_script.sh

kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/publish_commands.sh "${PUBLISHER_POD_NAME}":/tmp/publish_commands.sh

    kubectl -n "${NAMESPACE}" exec -i "${PUBLISHER_POD_NAME}" -- bash -c "/tmp/publish_commands.sh"