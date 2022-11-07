#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")

NETWORK_NAME="${PROJECT_NAME}"_default


# find non-tls and tls port
docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Ports.\"8080/tcp\"[0].HostPort"
docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Ports.\"8443/tcp\"[0].HostPort"
NON_TLS_PORT=$(docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Ports.\"8080/tcp\"[0].HostPort")
TLS_PORT=$(docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Ports.\"8443/tcp\"[0].HostPort")

# run curl in loop for different endpoints
for i in {1..3};
do
    echo "Attempt $i"
    docker run -d --net "$NETWORK_NAME" rapidfort/curl "-H Host:whoami.docker.localhost http://localhost:${NON_TLS_PORT}"
    docker run -d --net "$NETWORK_NAME" rapidfort/curl with_backoff "-H Host:whoami.docker.localhost https://localhost:${TLS_PORT}" -k
done