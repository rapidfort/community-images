#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker coverage = $JSON"

NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")
NETWORK_NAME=$(jq -r '.network_name' < "$JSON_PARAMS")
REPOSITORY=apache

# get docker host ip
APACHE_HOST=$(docker inspect "${NETWORK_NAME}" | jq -r ".[].NetworkSettings.Networks[\"${NETWORK_NAME}\"].IPAddress")

# Install Apache benchmark testing tool
sudo apt-get install apache2-utils -y
sudo apt-get install apache2 -y

# testing using apache benchmark tool
ab -t 100 -n 10000 -c 10 http://"${APACHE_HOST}":8080/