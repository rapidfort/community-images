#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"
NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")

CONTAINER_NAME="${NAMESPACE}"-kubectl-1

#kubectl test coverage
docker exec -i  "${CONTAINER_NAME}" ./tmp/coverage.sh