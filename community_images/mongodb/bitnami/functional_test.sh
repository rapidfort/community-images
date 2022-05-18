#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
. ${SCRIPTPATH}/../../common/helpers.sh

HELM_RELEASE=rf-mongodb
NAMESPACE=$(get_namespace_string ${HELM_RELEASE})

k8s_perf_runner()
{
    OPERATION=$1

    kubectl run -n ${NAMESPACE} mongodb-perf \
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

    docker run --rm -i --network=${DOCKER_NETWORK} --name mongodb-perf \
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

k8s_test()
{
    # install mongodb
    helm install ${HELM_RELEASE} bitnami/mongodb --set image.repository=rapidfort/mongodb --namespace ${NAMESPACE}

    # wait for mongodb
    kubectl wait deployments ${HELM_RELEASE} -n ${NAMESPACE} --for=condition=Available=True --timeout=10m

    # log pods
    kubectl -n ${NAMESPACE} get pods

    # get mongodb password
    MONGODB_ROOT_PASSWORD=$(kubectl get secret --namespace ${NAMESPACE} ${HELM_RELEASE} -o jsonpath="{.data.mongodb-root-password}" | base64 --decode)

    # run MongoDB tests
    k8s_perf_runner INSERT
    k8s_perf_runner UPDATE_MANY
    k8s_perf_runner ITERATE_MANY
    k8s_perf_runner DELETE_MANY

    # delte cluster
    helm delete ${HELM_RELEASE} --namespace ${NAMESPACE}

    # delete pvc
    kubectl -n ${NAMESPACE} delete pvc --all
}

docker_test()
{
    MONGODB_ROOT_PASSWORD=password123
    # create docker container
    docker run --rm -d -e "MONGODB_ROOT_PASSWORD=${MONGODB_ROOT_PASSWORD}" -p 27017:27017 \
        --name ${HELM_RELEASE} rapidfort/mongodb:latest

    # sleep for few seconds
    sleep 30

    # get docker host ip
    MONGODB_HOST=`docker inspect ${HELM_RELEASE} | jq -r '.[].NetworkSettings.Networks.bridge.IPAddress'`

    # run tests
    run_mongodb_test $MONGODB_HOST $MONGODB_ROOT_PASSWORD bridge

    # clean up docker container
    docker kill ${HELM_RELEASE}
}

docker_compose_test()
{
    # update image in docker-compose yml
    sed "s#@IMAGE#rapidfort/mongodb#g" ${SCRIPTPATH}/docker-compose.yml.base > ${SCRIPTPATH}/docker-compose.yml

    # install postgresql container
    docker-compose -f ${SCRIPTPATH}/docker-compose.yml -p ${NAMESPACE} up -d

    # sleep for 60 sec
    sleep 60

    # password
    MONGODB_ROOT_PASSWORD=password123

    # logs for tracking
    docker-compose -f ${SCRIPTPATH}/docker-compose.yml -p ${NAMESPACE} logs

    # run pg benchmark container
    run_mongodb_test mongodb-primary $MONGODB_ROOT_PASSWORD ${NAMESPACE}_default

    # kill docker-compose setup container
    docker-compose -f ${SCRIPTPATH}/docker-compose.yml -p ${NAMESPACE} down

    # clean up docker file
    rm -rf ${SCRIPTPATH}/docker-compose.yml
}

main()
{
    setup_namespace ${NAMESPACE}
    k8s_test
    docker_test
    docker_compose_test
    cleanup_namespace ${NAMESPACE}
}

main