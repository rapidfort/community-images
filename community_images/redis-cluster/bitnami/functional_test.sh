#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/helpers.sh

HELM_RELEASE=rf-redis-cluster
NAMESPACE=$(get_namespace_string "${HELM_RELEASE}")
IMAGE_REPOSITORY=rapidfort/redis-cluster

k8s_test()
{
    # setup namespace
    setup_namespace "${NAMESPACE}"

    # install redis
    with_backoff helm install "${HELM_RELEASE}" bitnami/redis-cluster --set image.repository="${IMAGE_REPOSITORY}" --namespace "${NAMESPACE}"
    report_pulls "${IMAGE_REPOSITORY}" 6

    # wait for redis
    kubectl wait pods "${HELM_RELEASE}"-0 -n "${NAMESPACE}" --for=condition=ready --timeout=10m

    # for logs dump pods
    kubectl -n "${NAMESPACE}" get pods

    # get password
    REDIS_PASSWORD=$(kubectl get secret --namespace "${NAMESPACE}" "${HELM_RELEASE}" -o jsonpath="{.data.redis-password}" | base64 --decode)

    # run redis-client
    kubectl run "${HELM_RELEASE}"-client --rm -i \
        --restart='Never' --namespace "${NAMESPACE}" \
        --image "${IMAGE_REPOSITORY}" --command \
        -- redis-benchmark -h "${HELM_RELEASE}" -c 20 -n 10000 -a "$REDIS_PASSWORD" --cluster
    report_pulls "${IMAGE_REPOSITORY}"

    # delete cluster
    helm delete "${HELM_RELEASE}" --namespace "${NAMESPACE}"

    # delete pvc
    kubectl -n "${NAMESPACE}" delete pvc --all

    # clean up namespace
    cleanup_namespace "${NAMESPACE}"
}

docker_compose_test()
{
    # update image in docker-compose yml
    sed "s#@IMAGE#${IMAGE_REPOSITORY}#g" "${SCRIPTPATH}"/docker-compose.yml.base > "${SCRIPTPATH}"/docker-compose.yml

    # install redis container
    docker-compose -f "${SCRIPTPATH}"/docker-compose.yml -p "${NAMESPACE}" up -d
    report_pulls "${IMAGE_REPOSITORY}" 6

    # sleep for 30 sec
    sleep 30

    # password
    REDIS_PASSWORD=bitnami

    # logs for tracking
    docker-compose -f "${SCRIPTPATH}"/docker-compose.yml -p "${NAMESPACE}" logs

    # run redis-client tests
    docker run --rm -d --network="${NAMESPACE}-default" \
        --name redis-bench-"${NAMESPACE}" "${IMAGE_REPOSITORY}":latest \
        sleep infinity
    report_pulls "${IMAGE_REPOSITORY}"

    # copy test.redis into container
    docker cp "${SCRIPTPATH}"/../../common/tests/test.redis redis-bench-"${NAMESPACE}":/tmp/test.redis

    # copy redis_cluster_runner.sh into container
    docker cp "${SCRIPTPATH}"/redis_cluster_runner.sh redis-bench-"${NAMESPACE}":/tmp/redis_cluster_runner.sh

    # run script in docker
    docker exec -i redis-bench-"${NAMESPACE}" /tmp/redis_cluster_runner.sh "${REDIS_PASSWORD}" redis-node-0 /tmp/test.redis

    # kill redis-bench
    docker kill redis-bench-"${NAMESPACE}"

    # kill docker-compose setup container
    docker-compose -f "${SCRIPTPATH}"/docker-compose.yml -p "${NAMESPACE}" down

    # clean up docker file
    rm -rf "${SCRIPTPATH}"/docker-compose.yml
}

main()
{
    k8s_test
    docker_compose_test
}

main