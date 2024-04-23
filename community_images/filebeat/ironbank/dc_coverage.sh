#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")
CONTAINER_NAME=${PROJECT_NAME}-filebeat-1

# Get the indices on stderr
curl -XGET 'http://localhost:9200/_cat/indices?v' >&2

# Check for availibilty of index of filebeat. (Checks for connection)
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