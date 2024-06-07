#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"
NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")
# Extracting names for ansible and ubuntu_host
AUDITBEAT_CONTAINER_NAME="${NAMESPACE}"-auditbeat-1

#Executing coverage commands for auditbeat
docker exec -i "${AUDITBEAT_CONTAINER_NAME}" bash -c /usr/share/auditbeat/test_coverage.sh
