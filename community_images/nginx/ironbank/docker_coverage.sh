#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker coverage = $JSON"

CONTAINER_NAME=$(jq -r '.container_details."nginx-ib".name' < "$JSON_PARAMS")

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/tests/sysbench_tests.sh

# copy common commands into container
docker cp "${SCRIPTPATH}"/../../common/tests/common_commands.sh "${CONTAINER_NAME}":/tmp/common_commands.sh

# run script
docker exec -i "${CONTAINER_NAME}" \
    /bin/bash -c "./tmp/common_commands.sh"