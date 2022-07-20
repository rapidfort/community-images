#!/bin/bash

set -x
set -e

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/helpers.sh


INPUT_REGISTRY=docker.io
INPUT_ACCOUNT=bitnami
REPOSITORY=envoy

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

    # exec into container and run coverage script
    docker exec -i "${NAMESPACE}"-envoy-1 bash -c /opt/bitnami/scripts/common_commands.sh

    # exec into container and run coverage script
    docker exec -i "${NAMESPACE}"-envoy-1 bash -c /opt/bitnami/scripts/coverage_script.sh

    # log for debugging
    docker inspect "${NAMESPACE}"-envoy-1

    # find non-tls and tls port
    NON_TLS_PORT=$(docker inspect "${NAMESPACE}"-envoy-1 | jq -r ".[].NetworkSettings.Ports.\"8080/tcp\"[0].HostPort")
    TLS_PORT=$(docker inspect "${NAMESPACE}"-envoy-1 | jq -r ".[].NetworkSettings.Ports.\"8443/tcp\"[0].HostPort")
    
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

    # do dynamic config test
    # create network
    docker network create -d bridge "${NAMESPACE}"

    # create docker container
    docker run --rm -d --network="${NAMESPACE}" \
        --name "${NAMESPACE}" \
        -v "${SCRIPTPATH}"/configs/dynamic/bootstrap.yaml:/opt/bitnami/envoy/conf/envoy.yaml \
        -v "${SCRIPTPATH}"/configs/dynamic:/etc/envoy \
        --cap-add=SYS_PTRACE \
        "${IMAGE_REPOSITORY}":"${TAG}"
    report_pulls "${IMAGE_REPOSITORY}"

    # sleep for few seconds
    sleep 30

    # get docker host ip
    ENVOY_HOST=$(docker inspect "${NAMESPACE}" | jq -r ".[].NetworkSettings.Networks[\"${NAMESPACE}\"].IPAddress")

    # run test on docker container
    docker run --rm --network="${NAMESPACE}" \
        -i alpine \
        apk add curl;curl http://"${ENVOY_HOST}":8081/ip;curl http://"${ENVOY_HOST}":9001/ready

    # clean up docker container
    docker kill "${NAMESPACE}"

    # delete network
    docker network rm "${NAMESPACE}"
}

declare -a BASE_TAG_ARRAY=("1.22.0-debian-11-r") # "1.21.2-debian-10-r" "1.20.3-debian-10-r" "1.19.4-debian-10-r")

build_images "${INPUT_REGISTRY}" "${INPUT_ACCOUNT}" "${REPOSITORY}" "${REPOSITORY}" test "${PUBLISH_IMAGE}" "${BASE_TAG_ARRAY[@]}"
