#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"
NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")


#PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")
#CONTAINER=cassandra-official-"${NAMESPACE}"

cp -v ./test.cql /tmp/

sleep 60

docker exec -i $(docker ps -a | grep cassandra | cut -f1 -d' ') bash -c 'cqlsh' < "/tmp/test.cql"
