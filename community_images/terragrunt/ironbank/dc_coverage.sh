#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")
CONTAINER_NAME=${PROJECT_NAME}-terragrunt-1
#version check
docker exec -i "${CONTAINER_NAME}" terragrunt -v
# testing commands
docker exec -i "${CONTAINER_NAME}" /tmp/commands.sh
# Terragrunt scaffolding can generate files for you automatically using boilerplate templates
docker exec -i -u root "${CONTAINER_NAME}" terragrunt scaffold github.com/gruntwork-io/terragrunt.git//test/fixture-hooks --terragrunt-working-dir=/run