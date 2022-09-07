#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

# PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")
