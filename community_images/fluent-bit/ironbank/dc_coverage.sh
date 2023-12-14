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
CONTAINER_NAME="${PROJECT_NAME}"-fluent-bit-1
# Wait
sleep 10
# log for debugging
docker inspect "${CONTAINER_NAME}"
docker exec -d "${CONTAINER_NAME}" /bin/bash -c "nohup /fluent-bit/bin/fluent-bit -c /tmp/fluent-bit2.config" &

sleep 10
# Get the PID of the last background process
DOCKER_PID=$(docker exec "${CONTAINER_NAME}" ps -e -o pid,cmd | grep '/fluent-bit/bin/fluent-bit' | awk '{print $1}')
# Check if the process is still running and terminate it if needed
if [ -n "${DOCKER_PID}" ]; then
    echo "Fluent Bit process is still running. Terminating..."
    docker exec "${CONTAINER_NAME}" kill "${DOCKER_PID}"
fi
