#!/bin/bash

set -e
set -x

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

function test_elasticsearch() {
    local NAMESPACE=$1
    local ES_SERVER=$2

    ESCLIENT_POD_NAME="elasticsearch-client"
    kubectl run "${ESCLIENT_POD_NAME}" --restart='Never' --image bitnami/python --namespace "${NAMESPACE}" --command -- sleep infinity
    # wait for publisher pod to come up
    kubectl wait pods "${ESCLIENT_POD_NAME}" -n "${NAMESPACE}" --for=condition=ready --timeout=10m
    echo "#!/bin/bash
    python -m pip install elasticsearch
    python3 /tmp/es_test.py --es-server=$ES_SERVER" > "$SCRIPTPATH"/es_commands.sh

    kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/es_test.py "${ESCLIENT_POD_NAME}":/tmp/es_test.py
    chmod +x "$SCRIPTPATH"/es_commands.sh
    kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/es_commands.sh "${ESCLIENT_POD_NAME}":/tmp/es_commands.sh

    kubectl -n "${NAMESPACE}" exec -i "${ESCLIENT_POD_NAME}" -- bash -c "/tmp/es_commands.sh"

    # delete the client containers
    kubectl -n "${NAMESPACE}" delete pod "${ESCLIENT_POD_NAME}"

    # delete the generated command files
    rm "$SCRIPTPATH"/es_commands.sh
}
