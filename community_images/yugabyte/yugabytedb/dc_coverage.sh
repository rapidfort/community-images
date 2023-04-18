#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")
CONTAINER_NAME="${PROJECT_NAME}"-yugabyte-1
YB_HOST=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "${CONTAINER_NAME}")

# log for debugging
docker inspect "${CONTAINER_NAME}"

# wait for container to be up
docker exec -i "${CONTAINER_NAME}" ./bin/yugabyted status

# copy test.psql into container
docker cp "${SCRIPTPATH}"/../../common/tests/test.psql "${CONTAINER_NAME}":/tmp/test.psql

# run script
docker exec -i "${CONTAINER_NAME}" ysqlsh -h "${YB_HOST}" -p 5433 -U yugabyte -d yugabyte -f /tmp/test.psql

# ysqlsh and ycqlsh
docker exec -i "${CONTAINER_NAME}" ysqlsh --version
docker exec -i "${CONTAINER_NAME}" ycqlsh --version

# exercise all webpages
UI_PORT=$(docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Ports.\"15433/tcp\"[0].HostPort")
HTML_DIR="${SCRIPTPATH}"/html_output
mkdir -p "${HTML_DIR}"
httrack http://"${YB_HOST}":"${UI_PORT}" -O "${HTML_DIR}"
rm -rf "${HTML_DIR}"
