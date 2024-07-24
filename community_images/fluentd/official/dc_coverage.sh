#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")
CONTAINER_NAME="${PROJECT_NAME}"-fluentd-1

# try installing a plugin
docker exec -i "$CONTAINER_NAME" fluent-gem install fluent-plugin-grep

# try installing a plugin using gem install
docker exec -i "$CONTAINER_NAME" gem install fluent-plugin-elasticsearch

# list fluent gem list
docker exec -i "$CONTAINER_NAME" fluent-gem list
# for fluent-debug
docker exec -i "$CONTAINER_NAME" gem install fiber-storage
# version
docker exec -i "$CONTAINER_NAME" fluentd --version
# List available formats for fluent-binlog-reader
docker exec -i "$CONTAINER_NAME" fluent-binlog-reader formats
docker exec -i "$CONTAINER_NAME" fluent-binlog-reader cat fluentd/etc/fluent.conf

# Get the PIDs
# PID=$(docker exec -i "$CONTAINER_NAME" pgrep -f fluentd | head -n 2)
PID='1
7'
# fluent-ctl using dump
docker exec -i "$CONTAINER_NAME" fluent-ctl dump "$PID"
docker exec -i "$CONTAINER_NAME" fluent-cat --help
# checking fluent-cap-ctl
docker exec -i "$CONTAINER_NAME" fluent-cap-ctl || echo 0
# format  with output set to null
docker exec -i "$CONTAINER_NAME" fluent-plugin-config-format output null
docker exec -i "$CONTAINER_NAME" fluent-ca-generate -help
# checking Generating Plugin Project Skeleton
docker exec -i "$CONTAINER_NAME" fluent-plugin-generate --help
# testing fluent-debug
(
  docker exec -i "$CONTAINER_NAME" fluent-debug <<EOF
  irb_quit
EOF
) || echo 0
