#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/scripts/bash_helper.sh

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")

# Container name for consul-server1
CONTAINER_NAME="${PROJECT_NAME}"-consul-server1-1

# Wait for all the member nodes to get in sync
sleep 20

# Consul ACLs
docker exec -i "${PROJECT_NAME}"-consul-server1-1 consul acl bootstrap

# Shutting down consul
docker exec -i "${CONTAINER_NAME}" consul leave