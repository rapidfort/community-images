#!/bin/bash

set -x
set -e

HELM_RELEASE=rf-redis-cluster
NAMESPACE=ci-test
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

test()
{
    # # install redis
    # helm install ${HELM_RELEASE} bitnami/redis-cluster --set image.repository=rapidfort/redis-cluster --namespace ${NAMESPACE}

    # # wait for redis
    # kubectl wait pods ${HELM_RELEASE}-0 -n ${NAMESPACE} --for=condition=ready --timeout=10m

    # # for logs dump pods
    # kubectl -n ${NAMESPACE} get pods

    # # get password
    # REDIS_PASSWORD=$(kubectl get secret --namespace ${NAMESPACE} ${HELM_RELEASE} -o jsonpath="{.data.redis-password}" | base64 --decode)

    # # run redis-client
    # kubectl run ${HELM_RELEASE}-client --rm -i --restart='Never' --namespace ${NAMESPACE} --image rapidfort/redis-cluster --command -- redis-benchmark -h ${HELM_RELEASE} -a "$REDIS_PASSWORD" --cluster

    # update image in docker-compose yml
    sed "s#@IMAGE#rapidfort/redis-cluster#g" ${SCRIPTPATH}/docker-compose.yml.base > ${SCRIPTPATH}/docker-compose.yml

    # install redis container
    docker-compose -f ${SCRIPTPATH}/docker-compose.yml up -d

    # sleep for 30 sec
    sleep 30

    # logs for tracking
    docker-compose -f ${SCRIPTPATH}/docker-compose.yml logs

    # run redis-client tests
    docker run --rm -i --network="bitnami_default" --name redis-bench rapidfort/redis-cluster:latest redis-benchmark -h bitnami_redis-node-0_1 -p 6379 -a "$REDIS_PASSWORD"
}

clean()
{
    # kill docker-compose setup container
    docker-compose -f ${SCRIPTPATH}/docker-compose.yml down

    # clean up docker file
    rm -rf ${SCRIPTPATH}/docker-compose.yml

    # prune containers
    docker image prune -a -f

    # # delete cluster
    # helm delete ${HELM_RELEASE} --namespace ${NAMESPACE}

    # # delete pvc
    # kubectl -n ${NAMESPACE} delete pvc --all
}

main()
{
    test
    clean
}

main