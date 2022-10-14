#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")

# Testing load balencer 
for i in {1..3};
do
    echo "Attempt $i"
    docker run -d -p "{$PROJECT_NAME}" rapidfort/curl "-H Host:whoami.docker.localhost http://127.0.0.1" 
    docker run -d -p "{$PROJECT_NAME}" rapidfort/curl "-H Host:whoami.docker.localhost http://127.0.0.1" 
    docker run -d -p "{$PROJECT_NAME}" rapidfort/curl "-H Host:whoami.docker.localhost http://127.0.0.1" 
done