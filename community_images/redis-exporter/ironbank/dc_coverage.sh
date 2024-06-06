#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

REDIS_MASTER_CONTAINER_NAME=redis-master
REDIS_SLAVE_CONTAINER_NAME=redis-slave

REDIS_EXP_CONTAINER_NAME=redis-exporter

# Executing Basic Commands for redis-master
docker exec -it redis-master redis-cli -a my_password PING
docker exec -it redis-master redis-cli -a my_password SET mykey "Hello"
docker exec -it redis-master redis-cli -a my_password GET mykey
docker exec -it redis-master redis-cli -a my_password INCR mycounter

# Executing Basic Commands for redis-slave
docker exec -it redis-slave redis-cli -a my_password PING
docker exec -it redis-slave redis-cli -a my_password GET mykey
docker exec -it redis-slave redis-cli -a my_password INCR mycounter

# fetching corresponding logs
docker exec -it redis-exporter /bin/bash -c "curl localhost:9121/metrics"
