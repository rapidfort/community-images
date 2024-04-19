#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"
NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")
NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")

CONTAINER_NAME="${NAMESPACE}"-terraform-1

# #Image Scanning
# docker exec -it "$CONTAINER_NAME" trivy image python:3.4-alpine

# #Repo Scanning
# docker exec -it "$CONTAINER_NAME" trivy repo  -f table https://github.com/aquasecurity/trivy-ci-test

#k8s cluster scannig
docker exec -i -u root "$CONTAINER_NAME" /bin/bash /terraform_coverage.sh