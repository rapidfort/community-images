#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")
CONTAINER_NAME=${PROJECT_NAME}-metricbeat-1

sleep 20
# testing commands
docker exec "${CONTAINER_NAME}" /bin/bash /tmp/test_commands.sh
# indices present 
curl -XGET 'http://localhost:9200/_cat/indices?v&pretty'
#To verify that statistics are present in Elasticsearch
curl -XGET 'http://localhost:9200/metricbeat-*/_search?pretty'

