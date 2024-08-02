#!/bin/bash

set -x
set -e

# Getting Runtime Rarameters

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

# Getting Container Names

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")
SOLR8_CONTAINER="${PROJECT_NAME}"-solr-1
ZOOKEEPER_CONTAINER="${PROJECT_NAME}"-zookeeper-1

# Getting Active Ports

SOLR8_PORT=$(docker inspect "${SOLR8_CONTAINER}" | jq -r ".[].NetworkSettings.Ports.\"8983/tcp\"[0].HostPort")
ZOOKEEPER_PORT=$(docker inspect "${ZOOKEEPER_CONTAINER}" | jq -r ".[].NetworkSettings.Ports.\"2181/tcp\"[0].HostPort")
SOLR8_BASE_URL="http://localhost:${SOLR8_PORT}/solr"
ZOOKEEPER_ADDRESS="${ZOOKEEPER_CONTAINER}:2181"

echo "Zookeeper Port = $ZOOKEEPER_PORT"
echo "Solr8 Port = $SOLR8_PORT"
echo "Solr8 Base URL = $SOLR8_BASE_URL"

# Running Coverage Script

docker exec -e ZOOKEEPER_ADDRESS="${ZOOKEEPER_ADDRESS}" "${SOLR8_CONTAINER}" /tmp/coverage.sh
