#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker coverage = $JSON"

SCRIPTPATH=$(jq -r '.image_script_dir' < "$JSON_PARAMS")
YB_HOST=$(jq -r '.container_details.yugabyte.ip_address' < "$JSON_PARAMS")

YB_CTR_NAME=$(jq -r '.container_details.yugabyte.name' < "$JSON_PARAMS")

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/scripts/bash_helper.sh

# Waiting for container to be configured
sleep 60

# wait for container to be up
with_backoff docker exec -i "${YB_CTR_NAME}" /bin/bash -c \
    "./bin/yugabyted status"


# copy test.psql into container
docker cp "${SCRIPTPATH}"/../../common/tests/test.psql "${YB_CTR_NAME}":/tmp/test.psql

# run script
docker exec -i "${YB_CTR_NAME}" /bin/bash -c \
    "ysqlsh -h ${YB_HOST} -p 5433 -U yugabyte -d yugabyte -f /tmp/test.psql"

# exercise all webpages
UI_PORT=$(docker inspect "${YB_CTR_NAME}" | jq -r ".[].NetworkSettings.Ports.\"15433/tcp\"[0].HostPort")
HTML_DIR="${SCRIPTPATH}"/html_output
mkdir -p "${HTML_DIR}"
httrack http://"${YB_HOST}":"${UI_PORT}" -O "${HTML_DIR}"
rm -rf "${HTML_DIR}"
