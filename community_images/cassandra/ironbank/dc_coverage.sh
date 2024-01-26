#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

# Sleep
sleep 60

# Fetching container Name
PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")
CONTAINER_NAME="${PROJECT_NAME}"-cassandra-1

# executing tests in the container
docker exec -i "${CONTAINER_NAME}" bash -c 'cqlsh -u cassandra -p cassandra < /opt/test.cql'

sleep 10
