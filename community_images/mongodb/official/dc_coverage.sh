#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")
CONTAINER="${PROJECT_NAME}"-mongo-1
# Get Port
#PORT=$(docker inspect "${PG_CONTAINER}" | jq -r ".[].NetworkSettings.Ports.\"5432/tcp\"[0].HostPort")

