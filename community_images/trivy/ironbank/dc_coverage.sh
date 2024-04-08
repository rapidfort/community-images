#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"
NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")
NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")

CONTAINER_NAME="${NAMESPACE}"-trivy-1

docker exec -it "$CONTAINER_NAME" trivy image python:3.4-alpine

docker exec -it "$CONTAINER_NAME" trivy repo  -f table https://github.com/aquasecurity/trivy-ci-test


