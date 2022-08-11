#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/scripts/bash_helper.sh

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")

CONTAINER_NAME="${PROJECT_NAME}"-envoy-1

# exec into container and run coverage script
docker exec -i "${CONTAINER_NAME}" bash -c /opt/bitnami/scripts/coverage_script.sh

# log for debugging
docker inspect "${CONTAINER_NAME}"

# find non-tls and tls port
NON_TLS_PORT=$(docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Ports.\"8080/tcp\"[0].HostPort")
TLS_PORT=$(docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Ports.\"8443/tcp\"[0].HostPort")

# run curl in loop for different endpoints
for i in {1..20};
do 
    echo "$i"
    curl http://localhost:"${NON_TLS_PORT}"/a
    curl http://localhost:"${NON_TLS_PORT}"/b
    with_backoff curl https://localhost:"${TLS_PORT}"/a -k -v
    with_backoff curl https://localhost:"${TLS_PORT}"/b -k -v
done

