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
# fetch service url and store the urls in URLS file
rm -f URLS
minikube service "${RELEASE_NAME}" -n "${NAMESPACE}" --url | tee -a URLS
# Changing "http" to "https" in the urls file
sed -i '2,2s/http/https/' URLS
cat URLS
# curl to urls
while read -r p;
do
    curl -k "${p}"
done <URLS
#Removing urls file
rm URLS
# fetch minikube ip
MINIKUBE_IP=$(minikube ip)
# curl to https url
curl https://"${MINIKUBE_IP}" -k
# Describe the service
kubectl describe svc "${RELEASE_NAME}" -n "${NAMESPACE}"
#Create ConfigMap for server block
kubectl -n "${NAMESPACE}" create configmap server-block-map --from-file=my_server_block.conf="${SCRIPTPATH}"/configs/nginx.conf
# Get the ConfigMap details
kubectl -n "${NAMESPACE}" get configmap server-block-map -o yaml
# Describe the ConfigMap
kubectl -n "${NAMESPACE}" describe configmap server-block-map

 
