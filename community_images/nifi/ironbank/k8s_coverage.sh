#!/bin/bash

set -x
set -e

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/scripts/bash_helper.sh

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for k8s coverage = $JSON"

NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")
RELEASE_NAME=$(jq -r '.release_name' < "$JSON_PARAMS")
CONTAINER_NAME="${RELEASE_NAME}"

kubectl exec -i "${CONTAINER_NAME}" -n "${NAMESPACE}" -- /opt/nifi/nifi-current/bin/nifi.sh
sleep 60
kubectl logs -n "${NAMESPACE}" "${CONTAINER_NAME}"
kubectl exec -i "${CONTAINER_NAME}" -n "${NAMESPACE}" -- tail -n 100 /opt/nifi/nifi-current/logs/nifi-app.log

kubectl exec -i "${CONTAINER_NAME}" -n "${NAMESPACE}" -- ls -l /opt/nifi/nifi-current/bin
kubectl exec -i "${CONTAINER_NAME}" -n "${NAMESPACE}" -- ps aux | grep nifi

kubectl exec -i "${CONTAINER_NAME}" -n "${NAMESPACE}" -- /opt/nifi/nifi-current/bin/nifi.sh list-processors
