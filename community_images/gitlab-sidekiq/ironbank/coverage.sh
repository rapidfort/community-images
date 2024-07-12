#!/bin/bash

set -e
set -x

function test_sidekiq() {
    POD_NAME=$1
    NAMESPACE=$2
    CONTAINER_NAME=$3

    CMD="kubectl exec -i -n "${NAMESPACE}" "${POD_NAME}" -c "${CONTAINER_NAME}" -- bash /srv/gitlab/coverage_script.sh"
    
    $CMD
}