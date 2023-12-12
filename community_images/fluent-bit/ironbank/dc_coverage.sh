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
docker cp "${SCRIPTPATH}"/scripts/fluent-bit_coverage_script.sh "${CONTAINER_NAME}":/tmp/fluent-bit_coverage_script.sh
docker exec -i ${CONTAINER_NAME} bash -c "bash /tmp/fluent-bit_coverage_script.sh"
