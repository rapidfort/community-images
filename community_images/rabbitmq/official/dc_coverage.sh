#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/coverage.sh

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")

RABBITMQ_SERVER=${PROJECT_NAME}-rabbitmq-1
RABBITMQ_NETWORK=${PROJECT_NAME}_default

RABBITMQ_USERNAME='user'
RABBITMQ_PASSWORD='password'

sleep 80
test_rabbitmq_docker_compose "${RABBITMQ_SERVER}" "${RABBITMQ_NETWORK}" "${RABBITMQ_USERNAME}" "${RABBITMQ_PASSWORD}"
