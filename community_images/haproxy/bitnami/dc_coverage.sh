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

CONTAINER_NAME=haproxy

# log for debugging
docker inspect "${CONTAINER_NAME}"

# finding port
docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Ports.\"80/tcp\"[0].HostPort"
PORT=$(docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Ports.\"80/tcp\"[0].HostPort")

# run curl in loop (roundrobin)
for i in {1..10};
do 
    echo "Attempt $i"
    curl http://localhost:"${PORT}"
done

# run curl in loop for app1 route
for i in {1..10};
do 
    echo "Attempt $i"
    curl http://localhost:"${PORT}"/app1
done

# run curl in loop for app2 route
for i in {1..10};
do 
    echo "Attempt $i"
    curl http://localhost:"${PORT}"/app2
done

# Running curl for admin (disabled by acl)
curl http://localhost:"${PORT}"/admin

# Changing load balancing mode from roundrobin to leastconn
docker exec -i "${CONTAINER_NAME}" cp /bitnami/haproxy/conf/haproxy.cfg /bitnami/haproxy/haproxy.cfg
docker exec -i "${CONTAINER_NAME}" sed -i 's/roundrobin/leastconn/g' /bitnami/haproxy/haproxy.cfg
docker exec -i "${CONTAINER_NAME}" cp /bitnami/haproxy/haproxy.cfg /bitnami/haproxy/conf/haproxy.cfg
# reloading
docker kill -s HUP haproxy
sleep 5
# Checking leastconn
# run curl in loop
for i in {1..10};
do 
    echo "Attempt $i"
    curl http://localhost:"${PORT}"
done

# Changing load balancing mode from leastconn to source mode
docker exec -i "${CONTAINER_NAME}" cp /bitnami/haproxy/conf/haproxy.cfg /bitnami/haproxy/haproxy.cfg
docker exec -i "${CONTAINER_NAME}" sed -i 's/leastconn/source/g' /bitnami/haproxy/conf/haproxy.cfg
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