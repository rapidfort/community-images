#!/bin/bash

set -ex

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")
CONTAINER_NAME="${PROJECT_NAME}"-fluentd-1

# try installing a plugin
docker exec -i "$CONTAINER_NAME" fluent-gem install fluent-plugin-grep

# try installing a plugin using gem install
docker exec -i "$CONTAINER_NAME" gem install fluent-plugin-prometheus

# list fluent gem list
docker exec -i "$CONTAINER_NAME" fluent-gem list
