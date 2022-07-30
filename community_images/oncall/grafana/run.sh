#!/bin/bash

set -x
set -e

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/helpers.sh


INPUT_REGISTRY=docker.io
INPUT_ACCOUNT=grafana
REPOSITORY=oncall

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

    # update image in docker-compose yml
    sed "s#@IMAGE#${IMAGE_REPOSITORY}:${TAG}#g" "${SCRIPTPATH}"/docker-compose.yml.base > "${SCRIPTPATH}"/docker-compose.yml

    # install docker container
    docker-compose --project-directory "${SCRIPTPATH}" -f "${SCRIPTPATH}"/docker-compose.yml -p "${NAMESPACE}" up --build -d
    report_pulls "${IMAGE_REPOSITORY}"

    # run pytest
    set +e #ignore test failures
    docker-compose --project-directory "${SCRIPTPATH}" -f "${SCRIPTPATH}"/docker-compose.yml -p "${NAMESPACE}" run engine python -m pytest
    set -e

    # issue token
    docker-compose --project-directory "${SCRIPTPATH}" -f "${SCRIPTPATH}"/docker-compose.yml -p "${NAMESPACE}" run engine python manage.py issue_invite_for_the_frontend --override
    
    # sleep for 30 sec
    sleep 30

    # logs for tracking
    docker-compose -f "${SCRIPTPATH}"/docker-compose.yml -p "${NAMESPACE}" logs
    
    # kill docker-compose setup container
    docker-compose -f "${SCRIPTPATH}"/docker-compose.yml -p "${NAMESPACE}" down

    # clean up docker file
    rm -rf "${SCRIPTPATH}"/docker-compose.yml
}

declare -a BASE_TAG_ARRAY=("v1.0.")

build_images "${INPUT_REGISTRY}" "${INPUT_ACCOUNT}" "${REPOSITORY}" "${REPOSITORY}" test "${PUBLISH_IMAGE}" "${BASE_TAG_ARRAY[@]}"

