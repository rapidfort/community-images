#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")

NETWORK_NAME="${PROJECT_NAME}"_default

# Get Dashboard
wget http://localhost:8080/dashboard

# Check Ping feature
curl -s http://localhost:8082/ping

# run curl in loop for different whoami endpoints
for i in {1..3};
do
    echo "Attempt $i"
    curl -H Host:whoami.docker.localhost https://localhost:9443 -k -s
done

