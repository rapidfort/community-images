#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for before k8s coverage = $JSON"

REPO_PATH=$(jq -r '.image_tag_details."vcluster-ib".repo_path' <<< "$JSON")
TAG=$(jq -r '.image_tag_details."vcluster-ib".tag' <<< "$JSON")

# tagging the stubbed image as latest
docker tag "${REPO_PATH}":"${TAG}" "${REPO_PATH}":latest

# load the image in minikube cluster
minikube image load "${REPO_PATH}":latest

# load the image in kind cluster
# kind load docker-image --name rapidfort-platform "${REPO_PATH}":latest

# Installing the vcluster CLI to communicate with the created vcluster
curl -L -o vcluster "https://github.com/loft-sh/vcluster/releases/latest/download/vcluster-linux-amd64" && sudo install -c -m 0755 vcluster /usr/local/bin