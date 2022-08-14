#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/helpers.sh

HELM_RELEASE=rf-prometheus
NAMESPACE=$(get_namespace_string "${HELM_RELEASE}")
REPOSITORY=prometheus
IMAGE_REPOSITORY="$RAPIDFORT_ACCOUNT"/"$REPOSITORY"

k8s_test()
{
    # setup namespace
    setup_namespace "${NAMESPACE}"

    # install helm
    #with_backoff helm install "${HELM_RELEASE}" bitnami/"$REPOSITORY" --set image.repository="$IMAGE_REPOSITORY" --set image.tag=latest --namespace "${NAMESPACE}"
    kubectl run "${HELM_RELEASE}" --restart='Never' --image "${IMAGE_REPOSITORY}":"${TAG}" --namespace "${NAMESPACE}" --privileged
    # wait for prometheus pod to come up
    kubectl wait pods "${HELM_RELEASE}" -n "${NAMESPACE}" --for=condition=ready --timeout=10m
    report_pulls "${IMAGE_REPOSITORY}"

    # wait for pods
    kubectl wait pods "${HELM_RELEASE}"-0 -n "${NAMESPACE}" --for=condition=ready --timeout=10m

    PROMETHEUS_SERVER=$(kubectl get pod "${HELM_RELEASE}" -n "${NAMESPACE}" --template '{{.status.podIP}}')
    PROMETHEUS_PORT=9090

    test_prometheus "${NAMESPACE}" "${PROMETHEUS_SERVER}" "${PROMETHEUS_PORT}"

    # bring down the pod
    kubectl delete pod "${HELM_RELEASE}" --namespace "${NAMESPACE}"

    # log pods
    kubectl -n "${NAMESPACE}" get pods
    kubectl -n "${NAMESPACE}" get svc

    # delete pvc
    kubectl -n "${NAMESPACE}" delete pvc --all

    # clean up namespace
    cleanup_namespace "${NAMESPACE}"
}

docker_test()
{
    # create network
    docker network create -d bridge "${NAMESPACE}"

    # create docker container
    docker run --rm -d --network="${NAMESPACE}" \
        --name "${NAMESPACE}" "$IMAGE_REPOSITORY":latest
    report_pulls "${IMAGE_REPOSITORY}"

    # sleep for few seconds
    sleep 30

    # clean up docker container
    docker kill "${NAMESPACE}"

    # delete network
    docker network rm "${NAMESPACE}"
}

docker_compose_test()
{
    # update image in docker-compose yml
    sed "s#@IMAGE#$IMAGE_REPOSITORY#g" "${SCRIPTPATH}"/docker-compose.yml.base > "${SCRIPTPATH}"/docker-compose.yml

    # install postgresql container
    docker-compose -f "${SCRIPTPATH}"/docker-compose.yml -p "${NAMESPACE}" up -d
    report_pulls "${IMAGE_REPOSITORY}"

    # sleep for 30 sec
    sleep 30

    # logs for tracking
    docker-compose -f "${SCRIPTPATH}"/docker-compose.yml -p "${NAMESPACE}" logs

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
