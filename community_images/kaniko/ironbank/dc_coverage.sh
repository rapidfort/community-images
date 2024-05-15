#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"
NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")

# Extracting names for ansible and ubuntu_host
KANIKO_CONTAINER_NAME="${NAMESPACE}"-kaniko-1

#Executing command inside kaniko container to build and push the image inside registry container
docker exec -i "${KANIKO_CONTAINER_NAME}"  /kaniko/executor --dockerfile=/workspace/Dockerfile --context=/workspace --destination=registry:5000/alpine:latest --insecure --insecure-pull

#Confirming if the registry got pushed or not
docker pull localhost:5001/alpine:latest

#cleaning up the pulled image
docker image remove localhost:5001/alpine:latest