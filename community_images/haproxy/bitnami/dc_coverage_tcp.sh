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

CONTAINER_NAME="${PROJECT_NAME}"-haproxy-1

# log for debugging
docker inspect "${CONTAINER_NAME}"

# finding port
docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Ports.\"80/tcp\"[0].HostPort"
PORT=$(docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Ports.\"80/tcp\"[0].HostPort")

# run curl in loop (roundrobin)
for i in {1..10};
do 
    echo "Attempt $i"
    curl http://localhost:"${PORT}"
done