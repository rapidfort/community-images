#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker coverage = $JSON"

APACHE_HOST=$(jq -r '.container_details."apache-official".ip_address' < "$JSON_PARAMS")

# Install Apache benchmark testing tool
sudo apt-get install apache2-utils -y
sudo apt-get install apache2 -y

# testing using apache benchmark tool
ab -t 100 -n 10000 -c 10 http://"${APACHE_HOST}":80/
