#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/scripts/bash_helper.sh

JSON_PARAMS="$1"
PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")
CONTAINER_NAME="${PROJECT_NAME}"-fluent-bit-1
# Wait
sleep 10
# log for debugging
docker inspect "${CONTAINER_NAME}"
docker exec -d "${CONTAINER_NAME}" /bin/bash -c "nohup /opt/bitnami/fluent-bit/bin/fluent-bit -c /tmp/fluent-bit2.config > /opt/bitnami/fluent-bit/logs/fluent-bit.log 2>&1 " &

sleep 10
# Get the PID of the last background process
DOCKER_PID=$(docker exec "${CONTAINER_NAME}" /bin/bash -c "pgrep -o fluent-bit")
# Check if the process is still running and terminate it if needed
if [ -n "${DOCKER_PID}" ]; then
    echo "Fluent Bit process is still running. Terminating..."
    docker exec "${CONTAINER_NAME}" kill "${DOCKER_PID}"
fi

