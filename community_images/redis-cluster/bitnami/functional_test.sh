#!/bin/bash

set -x
set -e

HELM_RELEASE=rf-redis-cluster
NAMESPACE=ci-test
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
. ${SCRIPTPATH}/../../common/helpers.sh

k8s_test()
{
    # install redis
    helm install ${HELM_RELEASE} bitnami/redis-cluster --set image.repository=rapidfort/redis-cluster --namespace ${NAMESPACE}

    # wait for redis
    kubectl wait pods ${HELM_RELEASE}-0 -n ${NAMESPACE} --for=condition=ready --timeout=10m

    # for logs dump pods
    kubectl -n ${NAMESPACE} get pods

    # get password
    REDIS_PASSWORD=$(kubectl get secret --namespace ${NAMESPACE} ${HELM_RELEASE} -o jsonpath="{.data.redis-password}" | base64 --decode)

    # run redis-client
    kubectl run ${HELM_RELEASE}-client --rm -i --restart='Never' --namespace ${NAMESPACE} --image rapidfort/redis-cluster --command -- redis-benchmark -h ${HELM_RELEASE} -a "$REDIS_PASSWORD" --cluster

    # delete cluster
    helm delete ${HELM_RELEASE} --namespace ${NAMESPACE}

    # delete pvc
    kubectl -n ${NAMESPACE} delete pvc --all
}

docker_compose_test()
{
    # update image in docker-compose yml
    sed "s#@IMAGE#rapidfort/redis-cluster#g" ${SCRIPTPATH}/docker-compose.yml.base > ${SCRIPTPATH}/docker-compose.yml

    # install redis container
    docker-compose -f ${SCRIPTPATH}/docker-compose.yml -p ${NAMESPACE} up -d

    # sleep for 30 sec
    sleep 30

    # password
    REDIS_PASSWORD=bitnami

    # logs for tracking
    docker-compose -f ${SCRIPTPATH}/docker-compose.yml -p ${NAMESPACE} logs

    # run redis-client tests
    docker run --rm -d --network="${NAMESPACE}_default" --name redis-bench rapidfort/redis-cluster:latest sleep infinity

    # copy test.redis into container
    docker cp ${SCRIPTPATH}/../../common/tests/test.redis redis-bench:/tmp/test.redis

    # copy redis_cluster_runner.sh into container
    docker cp ${SCRIPTPATH}/redis_cluster_runner.sh redis-bench:/tmp/redis_cluster_runner.sh

    # run script in docker
    docker exec -i redis-bench /tmp/redis_cluster_runner.sh ${REDIS_PASSWORD} redis-node-0 /tmp/test.redis

    # kill redis-bench
    docker kill redis-bench

    # kill docker-compose setup container
    docker-compose -f ${SCRIPTPATH}/docker-compose.yml -p ${NAMESPACE} down

    # clean up docker file
    rm -rf ${SCRIPTPATH}/docker-compose.yml
}

main()
{
    k8s_test
    docker_compose_test
}

main