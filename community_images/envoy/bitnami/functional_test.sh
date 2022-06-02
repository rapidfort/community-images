#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/helpers.sh

REPOSITORY=envoy
HELM_RELEASE=rf-"${REPOSITORY}"
NAMESPACE=$(get_namespace_string "${HELM_RELEASE}")


docker_test()
{
    # create network
    docker network create -d bridge "${NAMESPACE}"

    # create docker container
    docker run --rm -d --network="${NAMESPACE}" \
        --name "${NAMESPACE}" \
        -v "${SCRIPTPATH}"/configs/envoy_non_tls.yaml:/opt/bitnami/envoy/conf/envoy.yaml \
        "rapidfort/$REPOSITORY":latest
    report_pulls "rapidfort/$REPOSITORY"

    # sleep for few seconds
    sleep 30

    # get docker host ip
    ENVOY_HOST=$(docker inspect "${NAMESPACE}" | jq -r ".[].NetworkSettings.Networks[\"${NAMESPACE}\"].IPAddress")

    # run test on docker container
    docker run --rm --network="${NAMESPACE}" \
        -i alpine \
        apk add curl;curl http://"${ENVOY_HOST}":8080/ip

    # clean up docker container
    docker kill "${NAMESPACE}"

    # delete network
    docker network rm "${NAMESPACE}"
}

docker_compose_test()
{
    # create ssl certs
    create_certs

    # update image in docker-compose yml
    sed "s#@IMAGE#rapidfort/$REPOSITORY#g" "${SCRIPTPATH}"/docker-compose.yml.base > "${SCRIPTPATH}"/docker-compose.yml

    # install container
    docker-compose -f "${SCRIPTPATH}"/docker-compose.yml -p "${NAMESPACE}" up -d
    report_pulls "rapidfort/$REPOSITORY"

    # sleep for 30 sec
    sleep 30

    # find non-tls and tls port
    NON_TLS_PORT=$(docker inspect "${NAMESPACE}"_envoy_1 | jq -r ".[].NetworkSettings.Ports.\"8080/tcp\"[0].HostPort")
    TLS_PORT=$(docker inspect "${NAMESPACE}"_envoy_1 | jq -r ".[].NetworkSettings.Ports.\"8443/tcp\"[0].HostPort")
    curl http://localhost:"${NON_TLS_PORT}"/a
    curl http://localhost:"${NON_TLS_PORT}"/b
    curl https://localhost:"${TLS_PORT}"/a -k
    curl https://localhost:"${TLS_PORT}"/b -k

    # logs for tracking
    docker-compose -f "${SCRIPTPATH}"/docker-compose.yml -p "${NAMESPACE}" logs

    # kill docker-compose setup container
    docker-compose -f "${SCRIPTPATH}"/docker-compose.yml -p "${NAMESPACE}" down

    # clean up docker file
    rm -rf "${SCRIPTPATH}"/docker-compose.yml

    # clean up certs
    cleanup_certs
}

main()
{
    docker_test
    docker_compose_test
}

main