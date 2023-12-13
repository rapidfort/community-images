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
docker cp "${SCRIPTPATH}"/config/plugins.config "${CONTAINER_NAME}":/opt/bitnami/fluent-bit/conf/plugins.conf
# log for debugging
docker inspect "${CONTAINER_NAME}"
