#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

SCRIPTPATH=$(jq -r '.image_script_dir' < "$JSON_PARAMS")
NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")
RELEASE_NAME=$(jq -r '.release_name' < "$JSON_PARAMS")
REPOSITORY=apache

# get pod name
POD_NAME=$(kubectl -n "${NAMESPACE}" get pods -l app.kubernetes.io/name="$REPOSITORY" -o jsonpath="{.items[0].metadata.name}")

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