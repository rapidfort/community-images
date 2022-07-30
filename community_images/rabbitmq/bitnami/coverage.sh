#!/bin/bash

set -e
set -x

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

function test_rabbitmq() {
    local NAMESPACE=$1
    local RABBITMQ_SERVER=$2
    local RABBITMQ_PASS=$3

    PUBLISHER_POD_NAME="publisher"
    kubectl run "${PUBLISHER_POD_NAME}" --rm --restart='Never' --image bitnami/python --namespace "${NAMESPACE}" --command -- sleep infinity
    # wait for nats client to come up
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
    kubectl run "${CONSUMER_POD_NAME}" --rm --restart='Never' --image bitnami/python --namespace "${NAMESPACE}" --command -- sleep infinity
    # wait for nats client to come up
    kubectl wait pods "${CONSUMER_POD_NAME}" -n "${NAMESPACE}" --for=condition=ready --timeout=10m
    echo "#!/bin/bash
    pip install pika
    python3 /tmp/consume.py --rabbitmq-server=$RABBITMQ_SERVER --password=$RABBITMQ_PASS" > "$SCRIPTPATH"/consume_commands.sh

    kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/consume.py "${CONSUMER_POD_NAME}":/tmp/consume.py
    chmod +x "$SCRIPTPATH"/consume_commands.sh
    kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/consume_commands.sh "${CONSUMER_POD_NAME}":/tmp/consume_commands.sh

    kubectl -n "${NAMESPACE}" exec -i "${CONSUMER_POD_NAME}" -- bash -c "/tmp/consume_commands.sh"

    # delete the generated command files
    rm "$SCRIPTPATH"/publish_commands.sh
    rm "$SCRIPTPATH"/consume_commands.sh
}
