#!/bin/bash

set -x
set -e

HELM_RELEASE=rf-redis
NAMESPACE=ci-test
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
. ${SCRIPTPATH}/../../common/helpers.sh

k8s_test()
{
    # install redis
    helm install ${HELM_RELEASE} bitnami/redis --set image.repository=rapidfort/redis --namespace ${NAMESPACE}
    
    # wait for redis
    kubectl wait pods ${HELM_RELEASE}-master-0 -n ${NAMESPACE} --for=condition=ready --timeout=10m
    
    # for logs dump pods
    kubectl -n ${NAMESPACE} get pods

    # get password
    REDIS_PASSWORD=$(kubectl get secret --namespace ${NAMESPACE} ${HELM_RELEASE} -o jsonpath="{.data.redis-password}" | base64 --decode)
    
    # run redis-client
    kubectl run ${HELM_RELEASE}-client --rm -i --restart='Never' --namespace ${NAMESPACE} --image rapidfort/redis --command -- redis-benchmark -h ${HELM_RELEASE}-master -p 6379 -a "$REDIS_PASSWORD"

    # delete cluster
    helm delete ${HELM_RELEASE} --namespace ${NAMESPACE}
    
    # delete pvc
    kubectl -n ${NAMESPACE} delete pvc --all
}

docker_test()
{
    # password
    REDIS_PASSWORD=my_password

    # add redis container tests
    docker run --rm -d -p 6379:6379 -e "REDIS_PASSWORD=${REDIS_PASSWORD}" --name rf-redis rapidfort/redis:latest

    # sleep for 30 sec
    sleep 30

    # get host
    REDIS_HOST=`docker inspect rf-redis | jq -r '.[].NetworkSettings.Networks.bridge.IPAddress'`

    # run redis-client tests
    docker run --rm -i --name redis-bench rapidfort/redis:latest redis-benchmark -h ${REDIS_HOST} -p 6379 -a "$REDIS_PASSWORD"

    # clean up docker container
    docker kill rf-redis
}

docker_compose_test()
{
    # update image in docker-compose yml
    sed "s#@IMAGE#rapidfort/redis#g" ${SCRIPTPATH}/docker-compose.yml.base > ${SCRIPTPATH}/docker-compose.yml

    # install redis container
    docker-compose -f ${SCRIPTPATH}/docker-compose.yml -p ${NAMESPACE} up -d

    # sleep for 30 sec
    sleep 30

    # password
    REDIS_PASSWORD=my_password

    # logs for tracking
    docker-compose -f ${SCRIPTPATH}/docker-compose.yml -p ${NAMESPACE} logs

    # copy test.redis into container
    docker run --rm -i --network="${NAMESPACE}_default" --name redis-bench rapidfort/redis:latest redis-benchmark -h redis-primary -p 6379 -a "$REDIS_PASSWORD"

    # kill docker-compose setup container
    docker-compose -f ${SCRIPTPATH}/docker-compose.yml -p ${NAMESPACE} down

    # clean up docker file
    rm -rf ${SCRIPTPATH}/docker-compose.yml
}

main()
{
    k8s_test
    docker_test
    docker_compose_test
}

main