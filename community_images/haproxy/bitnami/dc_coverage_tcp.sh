#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/scripts/bash_helper.sh

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

CONTAINER_NAME=haproxy

# log for debugging
docker inspect "${CONTAINER_NAME}"

# finding port
docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Ports.\"80/tcp\"[0].HostPort"
PORT=$(docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Ports.\"80/tcp\"[0].HostPort")

# run curl in loop (roundrobin)
for i in {1..5};
do 
    echo "Attempt $i"
    curl http://localhost:"${PORT}"
done

# Changing compression algo from identity to gzip
docker exec -i "${CONTAINER_NAME}" cp /bitnami/haproxy/conf/haproxy.cfg /bitnami/haproxy/haproxy.cfg
docker exec -i "${CONTAINER_NAME}" sed -i 's/identity/gzip/g' /bitnami/haproxy/haproxy.cfg
docker exec -i "${CONTAINER_NAME}" cp /bitnami/haproxy/haproxy.cfg /bitnami/haproxy/conf/haproxy.cfg
# reloading
docker kill -s HUP haproxy
sleep 5
# Checking leastconn
# run curl in loop
for i in {1..4};
do 
    echo "Attempt $i"
    curl http://localhost:"${PORT}"
done

# Changing compression algo from gzip to deflate
docker exec -i "${CONTAINER_NAME}" cp /bitnami/haproxy/conf/haproxy.cfg /bitnami/haproxy/haproxy.cfg
docker exec -i "${CONTAINER_NAME}" sed -i 's/gzip/deflate/g' /bitnami/haproxy/conf/haproxy.cfg
docker exec -i "${CONTAINER_NAME}" cp /bitnami/haproxy/haproxy.cfg /bitnami/haproxy/conf/haproxy.cfg
# reloading
docker kill -s HUP haproxy
sleep 5
# Checking source mode
# run curl in loop
for i in {1..10};
do 
    echo "Attempt $i"
    curl http://localhost:"${PORT}"
done