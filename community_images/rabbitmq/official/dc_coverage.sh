#!/bin/bash

set -x
set -e

# shellcheck disable=SC1091
SCRIPTPATH="$(cd -- "$(dirname "$0")" >/dev/null 2>&1 pwd -P)"

JSON_PARAMS="$1"
JSON=$(cat "$JSON_PARAMS")
echo "Json params for docker compose coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")

# Container names for rabbitmq
CONTAINER_NAME="${PROJECT_NAME}"-rabbitmq-1
PUBLISHER_NAME="${PROJECT_NAME}"-publisher-1
CONSUMER_NAME="${PROJECT_NAME}"-consumer-1

# Running publish and consume commands
docker exec -i "${PUBLISHER_NAME}" bash -c "./coverage_script.sh"
docker exec -i "${CONSUMER_NAME}" bash -c "./coverage_script.sh"

# Running benchmark test
PERF_POD="perf-test"
DEFAULT_RABBITMQ_USER='user'
PERF_TEST_IMAGE_VERSION='2.18.0'
RABBITMQ_PASS='password'

docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Ports.\"5672/tcp\"[0].HostPort"
RABBITMQ_SERVER=$(docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Ports.\"5672/tcp\"[0].HostPort")

# run the perf benchmark test
docker run -it --name "${PERF_POD}"\
    --env RABBITMQ_PERF_TEST_LOGGERS=com.rabbitmq.perf=debug,com.rabbitmq.perf.Producer=debug \
    --env DEFAULT_RABBITMQ_USER="${DEFAULT_RABBITMQ_USER}" \
    --env RABBITMQ_PASS="${RABBITMQ_PASS}" \
    --env RABBITMQ_SERVER="${RABBITMQ_SERVER}" \
    pivotalrabbitmq/perf-test:"${PERF_TEST_IMAGE_VERSION}" \
    --uri amqp://"${DEFAULT_RABBITMQ_USER}":"${RABBITMQ_PASS}"@"${RABBITMQ_SERVER}" \
    --time 10

# check for message from perf test
out=$(docker logs "${PERF_POD}" | grep -ic 'consumer latency')
if (( out < 1 )); then
    echo "The perf benchmark didn't run properly"
    return 1
fi

# delete the perf container
docker stop "${PERF_POD}"
docker rm "${PERF_POD}"