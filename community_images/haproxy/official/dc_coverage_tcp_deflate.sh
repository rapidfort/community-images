#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/scripts/bash_helper.sh

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

# deflate mode
CONTAINER1_NAME=haproxy-1

# log for debugging
docker inspect "${CONTAINER1_NAME}"

# finding ports
docker inspect "${CONTAINER1_NAME}" | jq -r ".[].NetworkSettings.Ports.\"80/tcp\"[0].HostPort"
PORT1=$(docker inspect "${CONTAINER1_NAME}" | jq -r ".[].NetworkSettings.Ports.\"80/tcp\"[0].HostPort")

# Adding wait time to allow haproxy to pick configuration from file
sleep 10

# run curl in loop (deflate)
for i in {1..5};
do
    echo "Attempt $i"
    curl http://localhost:"${PORT1}"
done
