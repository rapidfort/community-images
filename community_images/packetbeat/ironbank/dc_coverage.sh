#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")
CONTAINER_NAME=${PROJECT_NAME}-packetbeat-1

# Check for availibilty of index of packetbeat. 
INDEX_NAME=$(curl -sXGET 'http://localhost:9200/_cat/indices' | awk '{print $3}')
if [[ -z "$INDEX_NAME" ]]; then
    echo "Index not found"
    exit 1
else
    echo "Index found: $INDEX_NAME"
fi

# Note: since we have used `network_mode: host` in packetbeat in docker-compose.yml
# even the curl call made above is sniffed by packetbeat (since its in host network)
# So, those packets are picked up by packetbeat and are a part of coverage script.

# Query all data from packetbeat
# these results are paginated, we are only querying for first page here
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
docker exec -i "${CONTAINER_NAME}" packetbeat version
docker exec -i "${CONTAINER_NAME}" packetbeat keystore list
