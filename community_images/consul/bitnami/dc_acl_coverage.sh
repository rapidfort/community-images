#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/scripts/bash_helper.sh

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

# Container name for consul-server1
CONTAINER_NAME=consul-server1

# Consul ACLs
docker exec -i consul-server1 consul acl bootstrap

# Registering a service
consul services register -name=web

# Consul connect
docker exec -i consul-server1 docker exec -i consul-server1 consul connect proxy -service=web

# Using consul debug
docker exec -i consul-server1 consul debug -interval=15s -duration=1m

