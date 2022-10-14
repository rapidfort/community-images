#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")

NON_TLS_PORT="82"
TLS_PORT="445"

# Testing load balencer 
for i in {1..3};
do
    echo "Attempt $i"
    curl -H Host:whoami.docker.localhost http://127.0.0.1:"${NON_TLS_PORT}"
    curl http://localhost:"${NON_TLS_PORT}"       
    with_backoff curl -H Host:whoami.docker.localhost http://127.0.0.1:"${TLS_PORT}" -k -v
    with_backoff curl -H Host:whoami.docker.localhost http://127.0.0.1:"${TLS_PORT}" -k -v
done