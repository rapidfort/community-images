#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/helpers.sh

HELM_RELEASE=rf-influxdb
NAMESPACE=$(get_namespace_string "${HELM_RELEASE}")
REPOSITORY=influxdb
IMAGE_REPOSITORY=rapidfort/"$REPOSITORY"

k8s_test()
{
    # setup namespace
    setup_namespace "${NAMESPACE}"

    # install helm
    with_backoff helm install "${HELM_RELEASE}" bitnami/"$REPOSITORY" --set image.repository="$IMAGE_REPOSITORY" --namespace "${NAMESPACE}"
    report_pulls "${IMAGE_REPOSITORY}"

    # wait for pods
    kubectl wait deployments "${HELM_RELEASE}" -n "${NAMESPACE}" --for=condition=Available=True --timeout=10m

    # get pod name
    POD_NAME=$(kubectl -n "${NAMESPACE}" get pods -l app.kubernetes.io/name="$REPOSITORY" -o jsonpath="{.items[0].metadata.name}")

    # get influxdb token
    INFLUXDB_TOKEN=$(kubectl get secret --namespace "${NAMESPACE}" "${HELM_RELEASE}" -o jsonpath="{.data.admin-user-token}" | base64 --decode)

    # copy tests into container
    kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/tests/example.csv "${POD_NAME}":/tmp/example.csv
    kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/tests/query.flux "${POD_NAME}":/tmp/query.flux

    # write data to db
    kubectl -n "${NAMESPACE}" exec -i "${POD_NAME}" -- influx write -t $INFLUXDB_TOKEN -b primary --org-id primary -f /tmp/example.csv

    # run query on db
    kubectl -n "${NAMESPACE}" exec -i "${POD_NAME}" -- influx query -t $INFLUXDB_TOKEN --org primary -f /tmp/query.flux

    # log pods
    kubectl -n "${NAMESPACE}" get pods
    kubectl -n "${NAMESPACE}" get svc

    # delte cluster
    helm delete "${HELM_RELEASE}" --namespace "${NAMESPACE}"

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