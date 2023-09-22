#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/scripts/bash_helper.sh

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

sleep 15
docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Ports.\"8443/tcp\"[0].HostPort"
TLS_PORT=$(docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Ports.\"8443/tcp\"[0].HostPort")

# run curl 
with_backoff curl https://localhost:"${TLS_PORT}" -k -v
