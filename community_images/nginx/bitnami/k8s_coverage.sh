#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")
RELEASE_NAME=$(jq -r '.release_name' < "$JSON_PARAMS")

# fetch service url and store the urls in URLS file
rm -f URLS
URL=$(minikube service "${RELEASE_NAME}" -n "${NAMESPACE}" --url)
sleep 20
TUNNEL_PORT=$(echo "${URL}" | awk -F: '{print $NF}')
echo "${TUNNEL_PORT}"
curl http://127.0.0.1:"${TUNNEL_PORT}"



