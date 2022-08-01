#!/bin/bash

set -e
set -x

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

function test_rabbitmq() {
    local NAMESPACE=$1
    local RABBITMQ_SERVER=$2
    local RABBITMQ_PASS=$3

    PUBLISHER_POD_NAME="publisher"
    kubectl run "${PUBLISHER_POD_NAME}" --restart='Never' --image bitnami/python --namespace "${NAMESPACE}" --command -- sleep infinity
    # wait for publisher pod to come up
    kubectl wait pods "${PUBLISHER_POD_NAME}" -n "${NAMESPACE}" --for=condition=ready --timeout=10m
    echo "#!/bin/bash
    pip install pika
    python3 /tmp/publish.py --rabbitmq-server=$RABBITMQ_SERVER --password=$RABBITMQ_PASS" > "$SCRIPTPATH"/publish_commands.sh

    kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/publish.py "${PUBLISHER_POD_NAME}":/tmp/publish.py
    chmod +x "$SCRIPTPATH"/publish_commands.sh
    kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/publish_commands.sh "${PUBLISHER_POD_NAME}":/tmp/publish_commands.sh

    kubectl -n "${NAMESPACE}" exec -i "${PUBLISHER_POD_NAME}" -- bash -c "/tmp/publish_commands.sh"

    # consumer specific
    CONSUMER_POD_NAME="consumer"
    kubectl run "${CONSUMER_POD_NAME}" --restart='Never' --image bitnami/python --namespace "${NAMESPACE}" --command -- sleep infinity
    # wait for consumer pod to come up
    kubectl wait pods "${CONSUMER_POD_NAME}" -n "${NAMESPACE}" --for=condition=ready --timeout=10m
    echo "#!/bin/bash
    pip install pika
    python3 /tmp/consume.py --rabbitmq-server=$RABBITMQ_SERVER --password=$RABBITMQ_PASS" > "$SCRIPTPATH"/consume_commands.sh

    kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/consume.py "${CONSUMER_POD_NAME}":/tmp/consume.py
    chmod +x "$SCRIPTPATH"/consume_commands.sh
    kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/consume_commands.sh "${CONSUMER_POD_NAME}":/tmp/consume_commands.sh

    kubectl -n "${NAMESPACE}" exec -i "${CONSUMER_POD_NAME}" -- bash -c "/tmp/consume_commands.sh"

    # delete the client containers
    kubectl -n "${NAMESPACE}" delete pod "${PUBLISHER_POD_NAME}"
    kubectl -n "${NAMESPACE}" delete pod "${CONSUMER_POD_NAME}"

    # delete the generated command files
    rm "$SCRIPTPATH"/publish_commands.sh
    rm "$SCRIPTPATH"/consume_commands.sh

    PERF_POD="perf-test"
    DEFAULT_RABBITMQ_USER='user'
    PERF_TEST_IMAGE_VERSION='2.18.0'

    # run the perf benchmark test
    kubectl run -it "${PERF_POD}" \
        --env RABBITMQ_PERF_TEST_LOGGERS=com.rabbitmq.perf=debug,com.rabbitmq.perf.Producer=debug \
        --image=pivotalrabbitmq/perf-test:"${PERF_TEST_IMAGE_VERSION}" \
        --namespace "${NAMESPACE}" -- \
        --uri amqp://"${DEFAULT_RABBITMQ_USER}":"${RABBITMQ_PASS}"@"${RABBITMQ_SERVER}" \
        --time 10

    # check for message from perf test
    out=$(kubectl logs "${PERF_POD}" -n "${NAMESPACE}" | grep -ic 'consumer latency')

   if (( out >= 1 )); then
    echo "The perf benchmark didn't run properly"
    return 1
   fi

    # delete the perf container
    kubectl -n "${NAMESPACE}" delete pod "${PERF_POD}"
}
