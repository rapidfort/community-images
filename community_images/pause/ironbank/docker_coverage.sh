#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

CONTAINER_NAME=$(jq -r '.container_details."pause-ib".name' < "$JSON_PARAMS")

docker run -d --name nginx --net=container:"$CONTAINER_NAME" --pid=container:"$CONTAINER_NAME" nginx:latest

docker stop nginx
docker remove nginx

