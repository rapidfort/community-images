#!/bin/bash

set -x
set -e

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
curl http://"${MINIKUBE_IP}" -k