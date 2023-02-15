#!/bin/bash

set -e
set -x

function test_zookeeper() {
    CONTAINER_NAME=$1

    CMD="docker exec -i ${CONTAINER_NAME} bash -c /tmp/coverage_script.sh"
    $CMD
}