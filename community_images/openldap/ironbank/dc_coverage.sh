#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"
NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")
CONTAINER_NAME="${NAMESPACE}"-openldap-1

#k8s cluster scannig
docker exec -i -u root "$CONTAINER_NAME" /bin/bash /coverage.sh