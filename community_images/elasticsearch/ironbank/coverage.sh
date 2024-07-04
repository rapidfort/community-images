#!/bin/bash

set -e
set -x

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/scripts/bash_helper.sh

function test_elasticsearch_using_kubectl() {
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

function test_elasticsearch() {
    local ES_SERVER=$1
    local ES_NETWORK=$2

    echo "#!/bin/bash
    python -m pip install elasticsearch
    python3 /tmp/es_test.py --es-server=$ES_SERVER" > "$SCRIPTPATH"/es_commands.sh
    chmod +x "$SCRIPTPATH"/es_commands.sh

    ESCLIENT_POD_NAME="elasticsearch-client"
    docker run --rm \
        --net "$ES_NETWORK" \
        --name "${ESCLIENT_POD_NAME}" \
        -v "${SCRIPTPATH}"/es_test.py:/tmp/es_test.py \
        -v "${SCRIPTPATH}"/es_commands.sh:/tmp/es_commands.sh \
        -d bitnami/python \
        bash -c 'sleep infinity'

    # wait for publisher pod to come up
    # shellcheck disable=SC1083
    until [ "$(docker inspect -f {{.State.Running}} elasticsearch-client)" == "true" ]; do sleep 1; done

    with_backoff docker exec -t "${ESCLIENT_POD_NAME}" bash /tmp/es_commands.sh

    # delete the client containers
    docker rm -f "${ESCLIENT_POD_NAME}" || echo "couldn't delete the client container ${ESCLIENT_POD_NAME}"

    # delete the generated command files
    rm "$SCRIPTPATH"/es_commands.sh
}
