#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")

# Container name for consul-node1
CONTAINER_NAME="${PROJECT_NAME}"-reverse-proxy-1

# log for debugging
docker inspect "${CONTAINER_NAME}"

NETWORK_NAME=$(jq -r '.network_name' < "$JSON_PARAMS")
# ENVOY_HOST=$(jq -r '.container_details.envoy.ip_address' < "$JSON_PARAMS")

# find non-tls and tls port
docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Ports.\"8080/tcp\"[0].HostPort"
docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Ports.\"8443/tcp\"[0].HostPort"
NON_TLS_PORT=$(docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Ports.\"8080/tcp\"[0].HostPort")
TLS_PORT=$(docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Ports.\"8443/tcp\"[0].HostPort")

for i in {1..5};
do
    echo "Attempt $i"
    curl http://localhost:"${NON_TLS_PORT}"/whoami
    curl http://localhost:"${NON_TLS_PORT}"/whoami        
    with_backoff curl https://localhost:"${TLS_PORT}"/whoami -k -v
    with_backoff curl https://localhost:"${TLS_PORT}"/whoami -k -v
done