#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

# PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")

## SERVICES & ROUTES
# add a new service
curl -i -s -X POST http://localhost:8001/services \
  --data name=example_service \
  --data url='http://mockbin.org'
  
