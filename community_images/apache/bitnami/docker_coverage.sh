#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker coverage = $JSON"

NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")
REPOSITORY=apache

# create network
docker network create -d bridge "${NAMESPACE}"

# create docker container
docker run --rm -d --network="${NAMESPACE}" \
    --name "${NAMESPACE}" "$REPOSITORY":latest

# sleep for few seconds
sleep 30

# get docker host ip
APACHE_HOST=$(docker inspect "${NAMESPACE}" | jq -r ".[].NetworkSettings.Networks[\"${NAMESPACE}\"].IPAddress")

# Install Apache benchmark testing tool
sudo apt-get install apache2-utils -y
sudo apt-get install apache2 -y

# testing using apache benchmark tool
ab -t 100 -n 10000 -c 10 http://"${APACHE_HOST}":8080/

# clean up docker container
docker kill "${NAMESPACE}"

# delete network
docker network rm "${NAMESPACE}"
