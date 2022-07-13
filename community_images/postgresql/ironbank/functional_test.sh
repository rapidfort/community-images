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

    # get docker host ip
    PG_HOST=$(docker inspect "${NAMESPACE}" | jq -r ".[].NetworkSettings.Networks[\"${NAMESPACE}\"].IPAddress")

    # run test on docker container
    docker run --rm --network="${NAMESPACE}" \
        -i --env="PGPASSWORD=PgPwd" "${IMAGE_REPOSITORY}" \
        -- pgbench --host "${PG_HOST}" -U postgres -d postgres -p 5432 -i -s 50
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

    # install postgresql container
    docker-compose -f "${SCRIPTPATH}"/docker-compose.yml -p "${NAMESPACE}" up -d
    report_pulls "${IMAGE_REPOSITORY}" 2

    # sleep for 30 sec
    sleep 30

    # password
    POSTGRES_PASSWORD=my_password

    # logs for tracking
    docker-compose -f "${SCRIPTPATH}"/docker-compose.yml -p "${NAMESPACE}" logs

    # run pg benchmark container
    docker run --rm -i --network="${NAMESPACE}_default" \
        --env="PGPASSWORD=${POSTGRES_PASSWORD}" "${IMAGE_REPOSITORY}" \
        -- pgbench --host postgresql-master -U postgres -d postgres -p 5432 -i -s 50
    report_pulls "${IMAGE_REPOSITORY}"

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