#!/bin/bash

function test_fluent-bit() {
    CONTAINER_NAME=$1

    CMD="docker exec -i ${CONTAINER_NAME} bash -c /tmp/fluent-bit_coverage_script.sh"
    $CMD