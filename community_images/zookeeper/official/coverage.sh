#!/bin/bash

set -e
set -x

function test_zookeeper() {
    CONTAINER_NAME=$1
    NAMESPACE=$2
    USE_KUBECTL=$3

    CMD="docker exec -i ${CONTAINER_NAME} bash -c /tmp/coverage_script.sh"

    if [[ "${USE_KUBECTL}" == "yes" ]]; then
        CMD="kubectl exec -i ${CONTAINER_NAME} -n ${NAMESPACE} -- bash /tmp/coverage_script.sh"
    fi

    $CMD
}