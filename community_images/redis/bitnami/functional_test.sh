#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/helpers.sh

HELM_RELEASE=rf-redis
NAMESPACE=$(get_namespace_string "${HELM_RELEASE}")
IMAGE_REPOSITORY=rapidfort/redis

k8s_test()
{
    # setup namespace
    setup_namespace "${NAMESPACE}"

    # install redis
    with_backoff helm install "${HELM_RELEASE}" bitnami/redis --set image.repository="${IMAGE_REPOSITORY}" --namespace "${NAMESPACE}"
    report_pulls "${IMAGE_REPOSITORY}" 2
    
    # wait for redis
    kubectl wait pods "${HELM_RELEASE}"-master-0 -n "${NAMESPACE}" --for=condition=ready --timeout=10m
    
    # for logs dump pods
    kubectl -n "${NAMESPACE}" get pods

    # get password
    REDIS_PASSWORD=$(kubectl get secret --namespace "${NAMESPACE}" "${HELM_RELEASE}" -o jsonpath="{.data.redis-password}" | base64 --decode)
    
    # run redis-client
    kubectl run "${HELM_RELEASE}"-client --rm -i --restart='Never' --namespace "${NAMESPACE}" --image "${IMAGE_REPOSITORY}" --command -- redis-benchmark -h "${HELM_RELEASE}"-master -p 6379 -a "$REDIS_PASSWORD"
    report_pulls "${IMAGE_REPOSITORY}"

    # delete cluster
    helm delete "${HELM_RELEASE}" --namespace "${NAMESPACE}"
    
    # delete pvc
    kubectl -n "${NAMESPACE}" delete pvc --all

    # clean up namespace
    cleanup_namespace "${NAMESPACE}"
}

docker_test()
{
    # password
    REDIS_PASSWORD=my_password

    # create network
    docker network create -d bridge "${NAMESPACE}"

    # add redis container tests
    docker run --rm -d --network="${NAMESPACE}" \
        -e "REDIS_PASSWORD=${REDIS_PASSWORD}" \
        --name "${NAMESPACE}" "${IMAGE_REPOSITORY}":latest
    report_pulls "${IMAGE_REPOSITORY}"

    # sleep for 30 sec
    sleep 30

    # get host
    REDIS_HOST=$(docker inspect "${NAMESPACE}" | jq -r ".[].NetworkSettings.Networks[\"${NAMESPACE}\"].IPAddress")

    # run redis-client tests
    docker run --rm -i --network="${NAMESPACE}" \
        "${IMAGE_REPOSITORY}":latest \
        redis-benchmark -h "${REDIS_HOST}" -p 6379 -a "${REDIS_PASSWORD}"
    report_pulls "${IMAGE_REPOSITORY}"

    # clean up docker container
    docker kill "${NAMESPACE}"

    # delete network
    docker network rm "${NAMESPACE}"
}

docker_compose_test()
{
    # update image in docker-compose yml
    sed "s#@IMAGE#${IMAGE_REPOSITORY}#g" "${SCRIPTPATH}"/docker-compose.yml.base > "${SCRIPTPATH}"/docker-compose.yml

    # install redis container
    docker-compose -f "${SCRIPTPATH}"/docker-compose.yml -p "${NAMESPACE}" up -d
    report_pulls "${IMAGE_REPOSITORY}" 2

    # sleep for 30 sec
    sleep 30

    # password
    REDIS_PASSWORD=my_password

    # logs for tracking
    docker-compose -f "${SCRIPTPATH}"/docker-compose.yml -p "${NAMESPACE}" logs

    # copy test.redis into container
    docker run --rm -i --network="${NAMESPACE}-default" \
        "${IMAGE_REPOSITORY}":latest \
        redis-benchmark -h redis-primary -p 6379 -a "${REDIS_PASSWORD}"
    report_pulls "${IMAGE_REPOSITORY}"

    # kill docker-compose setup container
    docker-compose -f "${SCRIPTPATH}"/docker-compose.yml -p "${NAMESPACE}" down

    # clean up docker file
    rm -rf "${SCRIPTPATH}"/docker-compose.yml
}

main()
{
    k8s_test
    docker_test
    docker_compose_test
}

main