#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/helpers.sh

HELM_RELEASE=rf-postgresql
NAMESPACE=$(get_namespace_string "${HELM_RELEASE}")
IMAGE_REPOSITORY="$RAPIDFORT_ACCOUNT"/postgresql12-ib

docker_test()
{
    # create network
    docker network create -d bridge "${NAMESPACE}"

    # create docker container
    docker run --rm -d --network="${NAMESPACE}" \
        -e 'POSTGRES_PASSWORD=PgPwd' \
        --name "${NAMESPACE}" "${IMAGE_REPOSITORY}":latest
    report_pulls "${IMAGE_REPOSITORY}"

    # sleep for few seconds
    sleep 30

    # run pgbench
    docker exec -i "${NAMESPACE}" pgbench -i -s 50

    # clean up docker container
    docker kill "${NAMESPACE}"

    # delete network
    docker network rm "${NAMESPACE}"
}

docker_compose_test()
{
    # update image in docker-compose yml
    sed "s#@IMAGE#${IMAGE_REPOSITORY}#g" "${SCRIPTPATH}"/docker-compose.yml.base > "${SCRIPTPATH}"/docker-compose.yml

    # install postgresql container
    docker-compose -f "${SCRIPTPATH}"/docker-compose.yml -p "${NAMESPACE}" up -d
    report_pulls "${IMAGE_REPOSITORY}" 2

    # sleep for 30 sec
    sleep 30

    # logs for tracking
    docker-compose -f "${SCRIPTPATH}"/docker-compose.yml -p "${NAMESPACE}" logs

    # run pgbench
    docker exec -i "${NAMESPACE}"-postgresql-1 pgbench -i -s 50

    # kill docker-compose setup container
    docker-compose -f "${SCRIPTPATH}"/docker-compose.yml -p "${NAMESPACE}" down

    # clean up docker file
    rm -rf "${SCRIPTPATH}"/docker-compose.yml
}

main()
{
    docker_test
    docker_compose_test
}

main