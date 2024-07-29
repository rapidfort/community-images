#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")
CONTAINER_NAME=${PROJECT_NAME}-cypress-included-1

docker exec -i "${CONTAINER_NAME}" cypress info

docker exec -i "${CONTAINER_NAME}" cypress --help

docker exec -i "${CONTAINER_NAME}" cypress --version

docker exec -i "${CONTAINER_NAME}" cypress verify

docker exec -i "${CONTAINER_NAME}" cypress install

docker exec -i "${CONTAINER_NAME}" cypress cache --help

docker exec -i "${CONTAINER_NAME}" npx cypress run --spec /e2e/cypress/integration/example.spec.js --browser chrome

docker exec -i "${CONTAINER_NAME}" npx cypress run --spec /e2e/cypress/integration/example.spec.js --browser edge

docker exec -i "${CONTAINER_NAME}" npx cypress run --spec /e2e/cypress/integration/example.spec.js --browser firefox

docker exec -i "${CONTAINER_NAME}" npx cypress run || echo 0

docker exec -i "${CONTAINER_NAME}" cypress cache list

docker exec -i "${CONTAINER_NAME}" cypress cache path

docker exec -i "${CONTAINER_NAME}" cypress cache list --size

docker exec -i "${CONTAINER_NAME}" npx cypress run --component || echo 0