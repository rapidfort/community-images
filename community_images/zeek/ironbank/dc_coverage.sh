#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")
CONTAINER_NAME=${PROJECT_NAME}-zeek-1

sleep 20
# zeek version
docker exec "${CONTAINER_NAME}" zeek --version
# zkg version
docker exec "${CONTAINER_NAME}" zkg --version
# zeekctl version
docker exec "${CONTAINER_NAME}" zeekctl --version
docker exec "${CONTAINER_NAME}" zeek --help

# testing all zeekctl shell commands
docker exec "${CONTAINER_NAME}" zeekctl <<EOF
install
deploy
start
status
capstats
scripts
check
cleanup
config
cron
df
exec
netstats
peerstatus
print nodes
nodes
stop
diag
quit
EOF
# testing sample script
docker exec "${CONTAINER_NAME}" zeek /tmp/hello.zeek
# using all zkg commands
docker exec "${CONTAINER_NAME}" /tmp/commands.sh
# test command in zeek

docker exec "${CONTAINER_NAME}" zeek --test
