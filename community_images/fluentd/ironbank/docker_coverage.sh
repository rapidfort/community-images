#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker coverage = $JSON"

CONTAINER_NAME=$(jq -r '.container_details."fluentd-ib".name' < "$JSON_PARAMS")

# try installing a plugin
docker exec -i "$CONTAINER_NAME" fluent-gem install fluent-plugin-grep

# try installing a plugin using gem install
docker exec -i "$CONTAINER_NAME" gem install fluent-plugin-elasticsearch

# list fluent gem list
docker exec -i "$CONTAINER_NAME" fluent-gem list
