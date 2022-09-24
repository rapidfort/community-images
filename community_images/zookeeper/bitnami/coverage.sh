#!/bin/bash

set -e
set -x

function test_zookeeper() {
    CONTAINER_NAME=$1
    docker exec -i "${CONTAINER_NAME}" bash -c /opt/bitnami/scripts/coverage_script.sh

    # log for debugging
    docker inspect "${CONTAINER_NAME}"
}