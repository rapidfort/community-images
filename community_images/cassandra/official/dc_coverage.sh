#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"
NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")


#cp -v ./test.cql /tmp/

sleep 60

docker exec -i "$(docker ps | grep "$NAMESPACE"-cassandra-1 | cut -f1 -d' ')" bash -c 'cqlsh -u cassandra -p cassandra < /opt/test.cql'

sleep 10


