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
#Create ConfigMap for server block
kubectl -n "${NAMESPACE}" create configmap server-block-map --from-file=my_server_block.conf="${SCRIPTPATH}"/configs/nginx.conf
# Get the ConfigMap details
kubectl -n "${NAMESPACE}" get configmap server-block-map -o yaml
# Describe the ConfigMap
kubectl -n "${NAMESPACE}" describe configmap server-block-map
 # Describe the service
kubectl describe svc "${RELEASE_NAME}" -n "${NAMESPACE}"

rm -f URLS
URL=$(minikube service "${RELEASE_NAME}" -n "${NAMESPACE}" --url)
TUNNEL_PORT=$(echo "${URL}" | awk -F: '{print $NF}')
echo "${TUNNEL_PORT}"
sleep 10
IP_ADDRESS=$(ps -ef | pgrep -f "docker.*${TUNNEL_PORT}" | pgrep -of '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | head -n1)
ps -ef | pgrep docker"${IP_ADDRESS}"
curl "${IP_ADDRESS}":"${TUNNEL_PORT}"



