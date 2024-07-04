#!/bin/bash

set -ex

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "JSON parameters = ${JSON}"

# Sleep
sleep 60

# Get the container name
PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")
CONTAINER_NAME="${PROJECT_NAME}"-cassandra-1

# Run the coverage tests
docker exec -i "${CONTAINER_NAME}" bash -c 'cqlsh -u cassandra -p cassandra < /tmp/test.cql'

sleep 10
