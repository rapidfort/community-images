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

CONTAINER_NAME="${PROJECT_NAME}"-apache-1

# exec into container and run coverage script
docker exec -i "${CONTAINER_NAME}" ls
docker exec -i "${CONTAINER_NAME}" httpd -M
docker exec -i "${CONTAINER_NAME}" sed -i '/LoadModule /d' conf/httpd.conf
docker exec -i "${CONTAINER_NAME}" tee < /usr/local/apache2/modules_list -a conf/httpd.conf
docker exec -i "${CONTAINER_NAME}" apachectl configtest
docker exec -i "${CONTAINER_NAME}" apachectl -k graceful
docker exec -i "${CONTAINER_NAME}" httpd -M

# log for debugging
docker inspect "${CONTAINER_NAME}"

# find non-tls and tls port
docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Ports.\"80/tcp\"[0].HostPort"
docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Ports.\"443/tcp\"[0].HostPort"
NON_TLS_PORT=$(docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Ports.\"80/tcp\"[0].HostPort")
TLS_PORT=$(docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Ports.\"443/tcp\"[0].HostPort")

# run curl in loop for different endpoints
for i in {1..20};
do
    echo "Attempt $i"
        curl http://localhost:"${NON_TLS_PORT}"
        #with_backoff curl https://localhost:"${TLS_PORT}" -k -v
done
