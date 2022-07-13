#!/bin/bash

set -x
set -e

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/helpers.sh


INPUT_REGISTRY=registry1.dso.mil
INPUT_ACCOUNT=ironbank/opensource/nginx
REPOSITORY=nginx

if [ "$#" -ne 1 ]; then
    PUBLISH_IMAGE="no"
else
    PUBLISH_IMAGE=$1
fi


test()
{
    local IMAGE_REPOSITORY=$1
    local TAG=$2
    local NAMESPACE=$3
    
    echo "Testing $REPOSITORY"

    # create ssl certs
    create_certs

    # update image in docker-compose yml
    sed "s#@IMAGE#${IMAGE_REPOSITORY}:${TAG}#g" "${SCRIPTPATH}"/docker-compose.yml.base > "${SCRIPTPATH}"/docker-compose.yml

    # install docker container
    docker-compose -f "${SCRIPTPATH}"/docker-compose.yml -p "${NAMESPACE}" up -d
    report_pulls "${IMAGE_REPOSITORY}"

    # sleep for 30 sec
    sleep 30

    # common commands
    docker exec -i "${NAMESPACE}"-nginx-1 bash -c "/tmp/common_commands.sh"

    # exec into container and run coverage script
    docker exec -i "${NAMESPACE}"-nginx-1 bash -c /opt/bitnami/scripts/coverage_script.sh

    # log for debugging
    docker inspect "${NAMESPACE}"-nginx-1

    # find non-tls and tls port
    NON_TLS_PORT=$(docker inspect "${NAMESPACE}"-nginx-1 | jq -r ".[].NetworkSettings.Ports.\"8080/tcp\"[0].HostPort")
    TLS_PORT=$(docker inspect "${NAMESPACE}"-nginx-1 | jq -r ".[].NetworkSettings.Ports.\"8443/tcp\"[0].HostPort")
    
    # run curl in loop for different endpoints
    for i in {1..20};
    do 
        echo "$i"
        curl http://localhost:"${NON_TLS_PORT}"/a
        curl http://localhost:"${NON_TLS_PORT}"/b
        with_backoff curl https://localhost:"${TLS_PORT}"/a -k -v
        with_backoff curl https://localhost:"${TLS_PORT}"/b -k -v
    done

    # logs for tracking
    docker-compose -f "${SCRIPTPATH}"/docker-compose.yml -p "${NAMESPACE}" logs

    # kill docker-compose setup container
    docker-compose -f "${SCRIPTPATH}"/docker-compose.yml -p "${NAMESPACE}" down

    # clean up docker file
    rm -rf "${SCRIPTPATH}"/docker-compose.yml

    # clean up certs
    cleanup_certs
}

# login to input registry
docker login "${INPUT_REGISTRY}" -u "${IB_DOCKER_USERNAME}" -p "${IB_DOCKER_PASSWORD}"

declare -a BASE_TAG_ARRAY=("latest")

build_images "${INPUT_REGISTRY}" "${INPUT_ACCOUNT}" "${REPOSITORY}" "${REPOSITORY}-ib" test "${PUBLISH_IMAGE}" "${BASE_TAG_ARRAY[@]}"
