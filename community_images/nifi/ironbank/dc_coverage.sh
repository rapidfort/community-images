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

CONTAINER_NAME="${PROJECT_NAME}"-nifi-1
sleep 10

# Start the NiFi template
docker exec -i "${CONTAINER_NAME}" /opt/nifi/nifi-current/bin/nifi.sh nifi start -f /tmp/test-template.xml
# Wait for the data flow to process some data
sleep 60

docker exec -i "${CONTAINER_NAME}" /opt/nifi/nifi-current/bin/nifi.sh nifi pg-list
docker exec -i "${CONTAINER_NAME}" /opt/nifi/nifi-current/bin/nifi.sh nifi status