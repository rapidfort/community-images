#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")
CONTAINER_NAME=${PROJECT_NAME}-logstash-1
CONTAINER_NAME2=${PROJECT_NAME}-elasticsearch-1
docker exec -i "${CONTAINER_NAME}" logstash --version

docker exec  "${CONTAINER_NAME}" logstash -t -f /usr/share/logstash/pipeline/logstash.conf

PORT1=$(docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Ports.\"9600/tcp\"[0].HostPort")
PORT2=$(docker inspect "${CONTAINER_NAME2}" | jq -r ".[].NetworkSettings.Ports.\"9200/tcp\"[0].HostPort")

docker exec "${CONTAINER_NAME}" ps aux | grep logstash
curl -XGET http://localhost:"${PORT1}"/_node/plugins
docker exec -d "${CONTAINER_NAME}" logstash -f /tmp/logstash.conf --path.data=/tmp
sleep 40
curl -XGET http://localhost:"${PORT2}"/_cat/indices?v
INDEX_NAME=$(curl -sXGET http://localhost:"${PORT2}"/_cat/indices?v | awk '{print $3}')
if [[ -z "$INDEX_NAME" ]]; then
    echo "Index not found"
    exit 1
else
    echo "Index found: $INDEX_NAME"
fi