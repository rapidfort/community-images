#!/bin/bash

#set -x
#set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

echo "$SCRIPTPATH"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/scripts/bash_helper.sh

# Source Env Variable for Variable replacement
. "${SCRIPTPATH}"/docker.env.temp

INFLUXDB_TOKEN=${DOCKER_INFLUXDB_INIT_ADMIN_TOKEN}
echo "INFLUXDB_TOKEN=${INFLUXDB_TOKEN}"

INFLUXDB_INIT_ORG=${DOCKER_INFLUXDB_INIT_ORG}
INFLUXDB_INIT_BUCKET=${DOCKER_INFLUXDB_INIT_BUCKET}

echo "INFLUXDB_INIT_ORG=${INFLUXDB_INIT_ORG}"
echo "INFLUXDB_INIT_BUCKET=${INFLUXDB_INIT_BUCKET}"

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")
CONTAINER_NAME="${PROJECT_NAME}"-influxdb-1

# Wait for all influxdb server to set up
sleep 20

# log for debugging
docker inspect "${CONTAINER_NAME}"
#echo $?
# find non-tls and tls port
PORT=$(docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Ports.\"8086/tcp\"[0].HostPort")
echo "influxdb port = $PORT"

# copy tests into container
docker cp ${SCRIPTPATH}/tests/example.csv "${CONTAINER_NAME}":/tmp/
#echo $?
docker cp ${SCRIPTPATH}/tests/query.flux "${CONTAINER_NAME}":/tmp/
#echo $?
# executing tests in the container, write data to influxdb
docker exec -it "${CONTAINER_NAME}" /bin/bash -c "influx write -t $INFLUXDB_TOKEN -b $INFLUXDB_INIT_BUCKET --org-id $INFLUXDB_INIT_ORG -f /tmp/example.csv"
#echo $?
# run query on db
docker exec -it "${CONTAINER_NAME}" /bin/bash -c "influx query -t $INFLUXDB_TOKEN --org $INFLUXDB_INIT_ORG -f /tmp/query.flux"
#echo $?
echo "Done testing the scripts, waiting for 10 seconds"
sleep 10
