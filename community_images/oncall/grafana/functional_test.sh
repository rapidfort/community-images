#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/helpers.sh

HELM_RELEASE=rf-grafana-oncall
NAMESPACE=$(get_namespace_string "${HELM_RELEASE}")
REPOSITORY=oncall
IMAGE_REPOSITORY=rapidfort/"$REPOSITORY"


docker_compose_test()
{
    # update image in docker-compose yml
    sed "s#@IMAGE#${IMAGE_REPOSITORY}#g" "${SCRIPTPATH}"/docker-compose.yml.base > "${SCRIPTPATH}"/docker-compose.yml

    # install docker container
    docker-compose --env-file "${SCRIPTPATH}"/.env_hobby -f "${SCRIPTPATH}"/docker-compose.yml -p "${NAMESPACE}" up --build -d
    report_pulls "${IMAGE_REPOSITORY}"

    # issue token
    docker-compose --env-file "${SCRIPTPATH}"/.env_hobby -f "${SCRIPTPATH}"/docker-compose.yml -p "${NAMESPACE}" run engine python manage.py issue_invite_for_the_frontend --override

    # sleep for 30 secs
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
    docker_compose_test
}

main