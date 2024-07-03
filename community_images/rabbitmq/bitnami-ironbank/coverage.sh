#!/bin/bash

set -ex

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

function test_rabbitmq_docker_compose() {
    local RABBITMQ_SERVER=$1
    local RABBITMQ_NETWORK=$2

    local RABBITMQ_USERNAME=$3
    local RABBITMQ_PASSWORD=$4

    PUBLISHER_POD_NAME="publisher"

    docker run --name ${PUBLISHER_POD_NAME} --rm -d --network ${RABBITMQ_NETWORK} bitnami/python sleep infinity
    sleep 20

    echo "#!/bin/bash
    pip install pika
    python3 /tmp/publish.py --rabbitmq-server=$RABBITMQ_SERVER --password=$RABBITMQ_PASSWORD" > "$SCRIPTPATH"/publish_commands.sh

    docker cp "${SCRIPTPATH}"/publish.py "${PUBLISHER_POD_NAME}":/tmp/publish.py
    chmod +x "$SCRIPTPATH"/publish_commands.sh
    docker cp "${SCRIPTPATH}"/publish_commands.sh "${PUBLISHER_POD_NAME}":/tmp/publish_commands.sh
    
    docker exec -i  "${PUBLISHER_POD_NAME}" bash -c "/tmp/publish_commands.sh"

    # consumer specific
    CONSUMER_POD_NAME="consumer"
    docker run --name ${CONSUMER_POD_NAME} --rm -d --network ${RABBITMQ_NETWORK} bitnami/python sleep infinity
    sleep 20

    echo "#!/bin/bash
    pip install pika
    python3 /tmp/consume.py --rabbitmq-server=$RABBITMQ_SERVER --password=$RABBITMQ_PASSWORD" > "$SCRIPTPATH"/consume_commands.sh

    docker cp "${SCRIPTPATH}"/consume.py "${CONSUMER_POD_NAME}":/tmp/consume.py
    chmod +x "$SCRIPTPATH"/consume_commands.sh
    docker cp "${SCRIPTPATH}"/consume_commands.sh "${CONSUMER_POD_NAME}":/tmp/consume_commands.sh

    docker exec -i  "${CONSUMER_POD_NAME}" bash -c "/tmp/consume_commands.sh"

    # delete the client containers
    docker stop ${PUBLISHER_POD_NAME}
    docker stop ${CONSUMER_POD_NAME}

    # delete the generated command files
    rm "$SCRIPTPATH"/publish_commands.sh
    rm "$SCRIPTPATH"/consume_commands.sh

    # Perf
    PERF_POD="perf-test"
    DEFAULT_RABBITMQ_USER='user'
    PERF_TEST_IMAGE_VERSION='2.18.0'

    sleep 15

    # run the perf benchmark test
    docker run -i --name ${PERF_POD} \
        --network ${RABBITMQ_NETWORK} \
        -e RABBITMQ_PERF_TEST_LOGGERS=com.rabbitmq.perf=debug,com.rabbitmq.perf.Producer=debug \
        pivotalrabbitmq/perf-test:"${PERF_TEST_IMAGE_VERSION}" \
        --uri amqp://"${DEFAULT_RABBITMQ_USER}":"${RABBITMQ_PASSWORD}"@"${RABBITMQ_SERVER}" \
        --time 10

    sleep 15
    # check for message from perf test
    out=$(docker logs "${PERF_POD}" | grep -ic 'consumer latency')

    if (( out < 1 )); then
        echo "The perf benchmark didn't run properly"
        return 1
    fi

    # delete the perf container
    docker stop ${PERF_POD}
    docker rm ${PERF_POD}
}
