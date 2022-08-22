#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/helpers.sh

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/selenium_helper.sh

HELM_RELEASE=rf-wordpress
NAMESPACE=$(get_namespace_string "${HELM_RELEASE}")
REPOSITORY=wordpress
IMAGE_REPOSITORY="$RAPIDFORT_ACCOUNT"/"$REPOSITORY"

k8s_test()
{
    # setup namespace
    setup_namespace "${NAMESPACE}"

    # install helm
    with_backoff helm install "${HELM_RELEASE}" bitnami/"$REPOSITORY" --set image.repository="$IMAGE_REPOSITORY" --set image.tag=latest --namespace "${NAMESPACE}"
    report_pulls "${IMAGE_REPOSITORY}"

    # wait for deployments
    kubectl wait deployments "${HELM_RELEASE}" -n "${NAMESPACE}" --for=condition=Available=true --timeout=10m

    WORDPRESS_SERVER="${HELM_RELEASE}"."${NAMESPACE}".svc.cluster.local

    test_selenium "${NAMESPACE}" "${WORDPRESS_SERVER}"

    # log pods
    kubectl -n "${NAMESPACE}" get pods
    kubectl -n "${NAMESPACE}" get svc

    # delete cluster
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

    DB_NAME="${NAMESPACE}-db"
    docker run -e MARIADB_ALLOW_EMPTY_ROOT_PASSWORD=yes \
     -e MARIADB_PASSWORD=password -e MARIADB_USER=bn_wordpress \
      -e MARIADB_DATABASE=bitnami_wordpress --network="${NAMESPACE}" \
       --name "${DB_NAME}" -d mariadb:latest

    # sleep for few seconds
    sleep 10

    # create docker container
    docker run --rm -d --network="${NAMESPACE}" \
        --name "${NAMESPACE}" -e WORDPRESS_DATABASE_HOST=wordpressdb \
         -e WORDPRESS_DATABASE_USER=bn_wordpress -e WORDPRESS_DATABASE_PASSWORD=password \
          -e WORDPRESS_DATABASE_NAME=bitnami_wordpress -e WORDPRESS_DATABASE_PORT_NUMBER=3306 \
           -e ALLOW_EMPTY_PASSWORD=yes "$IMAGE_REPOSITORY":latest
    report_pulls "${IMAGE_REPOSITORY}"

    # sleep for few seconds
    sleep 30

    # clean up docker container
    docker kill "${NAMESPACE}"

    # clean up the mariadb container
    docker kill "${DB_NAME}"

    # delete network
    docker network rm "${NAMESPACE}"
}

docker_compose_test()
{
    # update image in docker-compose yml
    sed "s#@IMAGE#$IMAGE_REPOSITORY#g" "${SCRIPTPATH}"/docker-compose.yml.base > "${SCRIPTPATH}"/docker-compose.yml

    # install wordpress container
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
