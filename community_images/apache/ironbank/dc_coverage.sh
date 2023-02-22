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

# checking all modules and config test
docker exec -i "${CONTAINER_NAME}" httpd -M
docker exec -i "${CONTAINER_NAME}" apachectl configtest

# log for debugging
docker inspect "${CONTAINER_NAME}"

# find non-tls and tls port
docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Ports.\"80/tcp\"[0].HostPort"
docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Ports.\"8443/tcp\"[0].HostPort"
NON_TLS_PORT=$(docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Ports.\"80/tcp\"[0].HostPort")
TLS_PORT=$(docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Ports.\"8443/tcp\"[0].HostPort")

# run curl in loop for different endpoints
# Apache Server 1 (MPM Event module enabled, ssl enabled)
for i in {1..5};
do
    echo "Attempt on Apache-server-1 $i"
        curl http://localhost:"${NON_TLS_PORT}"
        with_backoff curl https://localhost:"${TLS_PORT}" -k -v
done
# Apache Server 2 (MPM Prefork module enabled)
NON_TLS_PORT=$(docker inspect "${PROJECT_NAME}"-apache-prefork-mpm-1 | jq -r ".[].NetworkSettings.Ports.\"80/tcp\"[0].HostPort")
for i in {1..5};
do
    echo "Attempt on Apache-server-2 $i"
        curl http://localhost:"${NON_TLS_PORT}"
done
# Apache Server 3 (MPM Worker module enable)
NON_TLS_PORT=$(docker inspect "${PROJECT_NAME}"-apache-worker-mpm-1 | jq -r ".[].NetworkSettings.Ports.\"80/tcp\"[0].HostPort")
for i in {1..5};
do
    echo "Attempt on Apache-server-3 $i"
        curl http://localhost:"${NON_TLS_PORT}"
done

# Install Apache benchmark testing tool
sudo apt-get install apache2-utils -y
sudo apt-get install apache2 -y

APACHE_HOST=$(docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Networks.IPAddress")