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
CONTAINER_NAME="${PROJECT_NAME}"-nginx-1

# reloading nginx
docker exec -i "${CONTAINER_NAME}" nginx -s reload
docker exec -i "${CONTAINER_NAME}" cp -v
docker exec -i "${CONTAINER_NAME}" mkdir -v
docker exec -i "${CONTAINER_NAME}" chmod -v
docker exec -i "${CONTAINER_NAME}" ls -v
docker exec -i "${CONTAINER_NAME}" mv -v
docker exec -i "${CONTAINER_NAME}" rm -v
docker exec -i "${CONTAINER_NAME}" ln -v
docker exec -i "${CONTAINER_NAME}" rmdir -v 
docker exec -i "${CONTAINER_NAME}" chgrp -v
docker exec -i "${CONTAINER_NAME}" chown -v
docker exec -i "${CONTAINER_NAME}" touch -v
docker exec -i "${CONTAINER_NAME}" cat -v
docker exec -i "${CONTAINER_NAME}" grep -v
docker exec -i "${CONTAINER_NAME}" sed -v
docker exec -i "${CONTAINER_NAME}" tar -v
docker exec -i "${CONTAINER_NAME}" sort -v
docker exec -i "${CONTAINER_NAME}" head -v
docker exec -i "${CONTAINER_NAME}" date -v
docker exec -i "${CONTAINER_NAME}" clear -v

# find non-tls and tls port
docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Ports.\"8080/tcp\"[0].HostPort"
docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Ports.\"8443/tcp\"[0].HostPort"
NON_TLS_PORT=$(docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Ports.\"8080/tcp\"[0].HostPort")
TLS_PORT=$(docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Ports.\"8443/tcp\"[0].HostPort")

# run curl in loop for different endpoints
for i in {1..20};
do
    echo "Attempt $i"
    curl http://localhost:"${NON_TLS_PORT}"/a
    curl http://localhost:"${NON_TLS_PORT}"/b
    with_backoff curl https://localhost:"${TLS_PORT}"/a -k -v
    with_backoff curl https://localhost:"${TLS_PORT}"/b -k -v
done
