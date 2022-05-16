#!/bin/bash

set -x
set -e

HELM_RELEASE=rf-redis-cluster
NAMESPACE=ci-test

test()
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

    # add redis container tests
    docker run --rm -d -p 6379:6379 -e "REDIS_PASSWORD=${REDIS_PASSWORD}" --name rf-redis-cluster rapidfort/redis-cluster:latest

    # get host
    REDIS_HOST=`docker inspect rf-redis-cluster | jq -r '.[].NetworkSettings.Networks.bridge.IPAddress'`

    # run redis-client tests
    docker run --rm -i --name redis-bench rapidfort/redis-cluster:latest redis-benchmark -h ${REDIS_HOST} -p 6379 -a "$REDIS_PASSWORD"
}

clean()
{
    # clean up docker container
    docker kill rf-redis-cluster

    # prune containers
    docker image prune -a -f

    # delete cluster
    helm delete ${HELM_RELEASE} --namespace ${NAMESPACE}

    # delete pvc
    kubectl -n ${NAMESPACE} delete pvc --all
}

main()
{
    test
    clean
}

main