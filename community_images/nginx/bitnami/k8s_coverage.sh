#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")
RELEASE_NAME=$(jq -r '.release_name' < "$JSON_PARAMS")
 # Describe the service
kubectl describe svc "${RELEASE_NAME}" -n "${NAMESPACE}"
# # fetch service url and store the urls in URLS file
rm -f URLS
URL=$(minikube service "${RELEASE_NAME}" -n "${NAMESPACE}" --url)
sleep 20
echo "${URL}"
TUNNEL_PORT=$(echo "${URL}" | awk -F: '{print $NF}')
IP=$(curl ipinfo.io/ip)
curl http://"${IP}":"${TUNNEL_PORT}"


#Create ConfigMap for server block
kubectl -n "${NAMESPACE}" create configmap server-block-map --from-file=my_server_block.conf="${SCRIPTPATH}"/configs/nginx.conf
# Get the ConfigMap details
kubectl -n "${NAMESPACE}" get configmap server-block-map -o yaml
# Describe the ConfigMap
kubectl -n "${NAMESPACE}" describe configmap server-block-map

 
