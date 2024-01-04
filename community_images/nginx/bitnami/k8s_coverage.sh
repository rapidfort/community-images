#!/bin/bash

set -x
set -e
# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/scripts/bash_helper.sh

JSON_PARAMS="$1"

NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")
RELEASE_NAME=$(jq -r '.release_name' < "$JSON_PARAMS")
# Create ConfigMap for server block
kubectl -n "${NAMESPACE}" create configmap server-block-map --from-file=my_server_block.conf="${SCRIPTPATH}"/configs/nginx.conf
# Get the ConfigMap details
kubectl -n "${NAMESPACE}" get configmap server-block-map -o yaml
# Describe the ConfigMap
kubectl -n "${NAMESPACE}" describe configmap server-block-map
 # Describe the service
kubectl describe svc "${RELEASE_NAME}" -n "${NAMESPACE}"
#IP
CLUSTER_IP=$(kubectl get service "${RELEASE_NAME}" -n "${NAMESPACE}" -o jsonpath='{.spec.clusterIP}')
# Checking HTTP connection
with_backoff curl "https://${CLUSTER_IP}/ui" -k -v


