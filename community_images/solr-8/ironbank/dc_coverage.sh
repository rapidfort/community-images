#!/bin/bash

set -x
set -e

# Getting Runtime Rarameters

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

# Getting Active Ports

ZOOKEEPER_PORT=$(docker port zookeeper 2181 | head -n 1 | awk -F: '{print $2}')
SOLR8_PORT=$(docker port solr8 8983 | head -n 1 | awk -F: '{print $2}')
SOLR8_BASE_URL="http://localhost:${SOLR8_PORT}/solr"

echo "Solr8 Base URL = $SOLR8_BASE_URL"
echo "Active Zookeeper Port = $ZOOKEEPER_PORT"

# Running Coverage Script

docker exec -i solr8 /tmp/coverage.sh
