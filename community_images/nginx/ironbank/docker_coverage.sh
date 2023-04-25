#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

CONTAINER_NAME=$(jq -r '.container_details.nginx-ib.name' < "$JSON_PARAMS")
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"


# run common commands
docker cp "${SCRIPTPATH}"/../../common/tests/common_commands.sh "${CONTAINER_NAME}":/tmp/common_commands.sh
docker exec -i "${CONTAINER_NAME}" /tmp/common_commands.sh