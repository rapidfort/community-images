#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")

CONTAINER_NAME="${PROJECT_NAME}"-yq-1
# testing yaml
docker exec -i "${CONTAINER_NAME}" yq '.items[] | select(.id == 2).price' /tmp/test.yml
# version command
docker exec -i "${CONTAINER_NAME}" yq --version
docker exec -i "${CONTAINER_NAME}" yq '.items[] | select(.id == 1)' /tmp/test.yml
#Encode properties
docker exec -i "${CONTAINER_NAME}" yq -o=props /tmp/test.yml
# yaml to json
docker exec -i "${CONTAINER_NAME}" yq eval '.[]' /tmp/test.yml
# Perform arithmetic operations on
docker exec -i "${CONTAINER_NAME}" yq eval '.field * 2' <<< '{"field": 5}'
# Get the current timestamp
docker exec -i "${CONTAINER_NAME}" yq eval 'now' <<< ''
#array within JSON
docker exec -i "${CONTAINER_NAME}" yq eval 'length' <<< '[1, 2, 3]'
#simple operation
docker exec -i "${CONTAINER_NAME}" yq eval '.[] | select(.id == 2).price' <<< '[{"id": 1, "price": 10}, {"id": 2, "price": 20}]'
#new record
docker exec -i "${CONTAINER_NAME}" yq '.items += [{"id": 7, "name": "Product G", "price": 15, "category": "mobile", "stock": 150}]' /tmp/test.yml
#eval-all
docker exec -i "${CONTAINER_NAME}" yq eval-all 'select(fileIndex == 0) *+ select(fileIndex == 1)' /tmp/test.yml /tmp/test2.yml
# Reduce functionality
docker exec -i "${CONTAINER_NAME}" yq eval '.[] as $item ireduce (0; . + $item)' /tmp/test3.yml
docker exec -i "${CONTAINER_NAME}" yq '.[] as $item ireduce ({}; .[$item | .name] = ($item | .has) )' /tmp/test4.yml
