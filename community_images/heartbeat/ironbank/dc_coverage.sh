#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")
CONTAINER_NAME=${PROJECT_NAME}-heartbeat-1

# Check for availibilty of index of filebeat. (Indirect check for connection)
INDEX_NAME=$(curl -sXGET 'http://localhost:9200/_cat/indices' | awk '{print $3}')
if [[ -z "$INDEX_NAME" ]]; then
    echo "Index not found"
    exit 1
else
    echo "Index found: $INDEX_NAME"
fi

# Query all data from filebeat
curl -i -X POST \
   -H "Content-Type:application/json" \
   -d \
'{
    "query" : {
        "match_all" : {}
    }
}' \
 "http://localhost:9200/${INDEX_NAME}/_search?pretty=true"

# CLI coverage
docker exec -i "${CONTAINER_NAME}" heartbeat version
docker exec -i "${CONTAINER_NAME}" heartbeat --help

# Export current config
docker exec -i "${CONTAINER_NAME}" heartbeat export config
# Export ILM policy
docker exec -i "${CONTAINER_NAME}" heartbeat export ilm-policy
# Export kibana index pattern
docker exec -i "${CONTAINER_NAME}" heartbeat export index-pattern
# Export index template
docker exec -i "${CONTAINER_NAME}" heartbeat export template


# Create a keystore
docker exec -i "${CONTAINER_NAME}" heartbeat keystore create
# List all keystores
docker exec -i "${CONTAINER_NAME}" heartbeat keystore list

# Test configuration settings from YAML file
docker exec -i "${CONTAINER_NAME}" heartbeat test config /usr/share/heartbeat/heartbeat.yml
# Test metricbeat can connect to the output by using the current settings
docker exec -i "${CONTAINER_NAME}" heartbeat test output

