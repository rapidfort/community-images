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

minikube tunnel
kubectl get svc
EXTERNAL_IP=$(kubectl get svc "${RELEASE_NAME}" -n "${NAMESPACE}" -o jsonpath='{.spec.externalIP}')
PORT=$(kubectl get svc "${RELEASE_NAME}" -n "${NAMESPACE}" -o jsonpath='{.spec.ports[0].port}')
curl http://"${EXTERNAL_IP}":"${PORT}"

# Describe the service
kubectl describe svc "${RELEASE_NAME}" -n "${NAMESPACE}"


#Create ConfigMap for server block
kubectl -n "${NAMESPACE}" create configmap server-block-map --from-file=my_server_block.conf="${SCRIPTPATH}"/configs/nginx.conf
# Get the ConfigMap details
kubectl -n "${NAMESPACE}" get configmap server-block-map -o yaml
# Describe the ConfigMap
kubectl -n "${NAMESPACE}" describe configmap server-block-map

 
