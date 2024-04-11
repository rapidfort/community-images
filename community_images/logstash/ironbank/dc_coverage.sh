#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")
CONTAINER_NAME=${PROJECT_NAME}-logstash-1

docker exec -i "${CONTAINER_NAME}" logstash --version

docker exec  "${CONTAINER_NAME}" logstash -t -f /usr/share/logstash/pipeline/logstash.conf

docker exec "${CONTAINER_NAME}" ps aux | grep logstash
