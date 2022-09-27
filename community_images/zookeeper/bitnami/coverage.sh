#!/bin/bash

set -e
set -x

function test_zookeeper() {
    CONTAINER_NAME=$1
    NAMESPACE=$2
    USE_KUBECTL=$3

    CMD="docker"

    if [[ "${USE_KUBECTL}" == "yes" ]]; then
        CMD="kubectl"
    fi
   

    "${CMD}" exec -i "${CONTAINER_NAME}" -n "${NAMESPACE}" bash /opt/bitnami/scripts/coverage_script.sh
}