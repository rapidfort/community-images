#!/bin/bash

set -x
set -e
# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/scripts/bash_helper.sh

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")

CONTAINER_NAME="${PROJECT_NAME}"-node-exporter-1
docker inspect "${CONTAINER_NAME}"
sleep 5

docker exec "${CONTAINER_NAME}" /opt/bitnami/node-exporter/bin/node_exporter --version

# Check the metrics using cURL for node-exporter
curl http://localhost:9100/metrics
curl http://localhost:9100/metrics/cpu
curl http://localhost:9100/metrics | grep "node_"
# checking for prometheus instance 
curl -L http://localhost:9090/graph
curl http://localhost:9090/targets
curl http://localhost:9090/api/v1/query?query=node_memory_MemFree_bytes
# Query for node_cpu_seconds_total
curl http://localhost:9090/api/v1/query?query=node_cpu_seconds_total
curl http://localhost:9090/metrics