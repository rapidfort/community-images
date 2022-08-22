#!/bin/bash

set -x
set -e

k8s_perf_runner()
{
    NAMESPACE=$1
    OPERATION=$2
    HELM_RELEASE=$3
    MONGODB_ROOT_PASSWORD=$4

    kubectl run -n "${NAMESPACE}" mongodb-perf \
        --rm -i --restart='Never' \
        --env="MONGODB_OPERATION=${OPERATION}" \
        --env="MONGODB_HOST=${HELM_RELEASE}" \
        --env="MONGODB_ROOT_PASSWORD=${MONGODB_ROOT_PASSWORD}" \
        --image rapidfort/mongodb-perfomance-test:latest
}

run_mongodb_test_op()
{
    MONGODB_HOST=$1
    MONGODB_ROOT_PASSWORD=$2
    DOCKER_NETWORK=$3
    OPERATION=$4

    docker run --rm -i --network="${DOCKER_NETWORK}" \
        -e "MONGODB_OPERATION=${OPERATION}" \
        -e "MONGODB_HOST=${MONGODB_HOST}" \
        -e "MONGODB_ROOT_PASSWORD=${MONGODB_ROOT_PASSWORD}" \
        rapidfort/mongodb-perfomance-test:latest
}

run_mongodb_test()
{
    MONGODB_HOST=$1
    MONGODB_ROOT_PASSWORD=$2
    DOCKER_NETWORK=$3

    run_mongodb_test_op "${MONGODB_HOST}" "${MONGODB_ROOT_PASSWORD}" "${DOCKER_NETWORK}" INSERT
    run_mongodb_test_op "${MONGODB_HOST}" "${MONGODB_ROOT_PASSWORD}" "${DOCKER_NETWORK}" UPDATE_MANY
    run_mongodb_test_op "${MONGODB_HOST}" "${MONGODB_ROOT_PASSWORD}" "${DOCKER_NETWORK}" ITERATE_MANY
    run_mongodb_test_op "${MONGODB_HOST}" "${MONGODB_ROOT_PASSWORD}" "${DOCKER_NETWORK}" DELETE_MANY
}