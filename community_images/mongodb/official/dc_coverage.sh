#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")
CONTAINER="${PROJECT_NAME}"-mongodb-1
# Run common mongo commands
docker exec -i "${CONTAINER}" bash -c "/tmp/mongodb_coverage.sh"
# Use MongoDB
docker exec -i "${CONTAINER}" bash -c "mongosh -u root -p rootpassword < /tmp/use_mongodb.js || mongo -u root -p rootpassword < /tmp/use_mongodb.js"

