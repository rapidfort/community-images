#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")
CONTAINER_NAME="${PROJECT_NAME}"-reverse-proxy-1

# log for debugging
docker inspect "${CONTAINER_NAME}"

# find non-tls and tls port
docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Ports.\"80/tcp\"[0].HostPort"
docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Ports.\"443/tcp\"[0].HostPort"
docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Ports.\"8080/tcp\"[0].HostPort"
docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Ports.\"8082/tcp\"[0].HostPort"

NON_TLS_PORT=$(docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Ports.\"80/tcp\"[0].HostPort")
TLS_PORT=$(docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Ports.\"443/tcp\"[0].HostPort")
ADMIN_PORT=$(docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Ports.\"8080/tcp\"[0].HostPort")
PING_PORT=$(docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Ports.\"8082/tcp\"[0].HostPort")

# Get Dashboard
wget http://localhost:"${ADMIN_PORT}"/dashboard
cat dashboard
rm dashboard
# Check Ping feature (traefik healthcheck)
curl -s http://localhost:"${PING_PORT}"/ping

# run curl in loop for different endpoints
for i in {1..3};
do 
    echo "Attempt $i"
    curl https://localhost:"${TLS_PORT}" --header 'Host:whoami.docker.localhost' https://localhost:"${TLS_PORT}" -k -s
    curl http://localhost:"${NON_TLS_PORT}" --header 'Host:whoami.docker.localhost' -s
done
