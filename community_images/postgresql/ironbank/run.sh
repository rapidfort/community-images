#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/helpers.sh

INPUT_REGISTRY=registry1.dso.mil
INPUT_ACCOUNT=ironbank/opensource/postgres
REPOSITORY=postgresql12

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
    local HELM_RELEASE=postgresql-release
    
    echo "Testing postgresql"

    # update image in docker-compose yml
    sed "s#@IMAGE#${IMAGE_REPOSITORY}:${TAG}#g" "${SCRIPTPATH}"/docker-compose.yml.base > "${SCRIPTPATH}"/docker-compose.yml

    POSTGRES_PASSWORD=my_password

    # install container
    docker-compose -f "${SCRIPTPATH}"/docker-compose.yml -p "${NAMESPACE}" up -d
    report_pulls "${IMAGE_REPOSITORY}"

    # sleep for 30 sec
    sleep 30

    # common commands
    docker exec -i "${NAMESPACE}"-postgresql-1 bash -c "/tmp/common_commands.sh"

    # run redis tests
    docker exec -i "${NAMESPACE}"-postgresql-1 bash -c "PGPASSWORD=${POSTGRES_PASSWORD} psql --host localhost -U postgres -d postgres -p 5432 -f /tmp/test.psql"

    # run redis coverage
    docker exec -i "${NAMESPACE}"-postgresql-1 bash -c "/tmp/postgres_coverage.sh"

    # logs for tracking
    docker-compose -f "${SCRIPTPATH}"/docker-compose.yml -p "${NAMESPACE}" logs

    # kill docker-compose setup container
    docker-compose -f "${SCRIPTPATH}"/docker-compose.yml -p "${NAMESPACE}" down

    # clean up docker file
    rm -rf "${SCRIPTPATH}"/docker-compose.yml
}

# login to input registry
docker login "${INPUT_REGISTRY}" -u "${IB_DOCKER_USERNAME}" -p "${IB_DOCKER_PASSWORD}"

declare -a BASE_TAG_ARRAY=("latest")

build_images "${INPUT_REGISTRY}" "${INPUT_ACCOUNT}" "${REPOSITORY}" "${REPOSITORY}-ib" test "${PUBLISH_IMAGE}" "${BASE_TAG_ARRAY[@]}"

