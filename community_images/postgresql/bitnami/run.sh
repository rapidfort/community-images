#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/helpers.sh

INPUT_REGISTRY=docker.io
INPUT_ACCOUNT=bitnami
REPOSITORY=postgresql

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

    # upgrade helm
    helm repo update

    # Install postgresql
    with_backoff helm install "${HELM_RELEASE}" "${INPUT_ACCOUNT}"/"${REPOSITORY}" --namespace "${NAMESPACE}" --set image.tag="${TAG}" --set image.repository="${IMAGE_REPOSITORY}" -f "${SCRIPTPATH}"/overrides.yml
    report_pulls "${IMAGE_REPOSITORY}"

    # waiting for pod to be ready
    echo "waiting for pod to be ready"
    kubectl wait pods "${HELM_RELEASE}"-0 -n "${NAMESPACE}" --for=condition=ready --timeout=10m

    # get postgresql passwordk
    POSTGRES_PASSWORD=$(kubectl get secret --namespace "${NAMESPACE}" "${HELM_RELEASE}" -o jsonpath="{.data.postgres-password}" | base64 --decode)

    # copy test.psql into container
    kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/../../common/tests/test.psql "${HELM_RELEASE}"-0:/tmp/test.psql

    # run script
    kubectl -n "${NAMESPACE}" exec -i "${HELM_RELEASE}"-0 -- /bin/bash -c "PGPASSWORD=${POSTGRES_PASSWORD} psql --host localhost -U postgres -d postgres -p 5432 -f /tmp/test.psql"

    # copy common_commands.sh into container
    kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/../../common/tests/common_commands.sh "${HELM_RELEASE}"-0:/tmp/common_commands.sh

    # run command on cluster
    kubectl -n "${NAMESPACE}" exec -i "${HELM_RELEASE}"-0 -- /bin/bash -c "/tmp/common_commands.sh"

    # copy postgres_coverage.sh into container
    kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/../../common/tests/postgres_coverage.sh "${HELM_RELEASE}"-0:/tmp/postgres_coverage.sh

    # run postgres_coverage on cluster
    kubectl -n "${NAMESPACE}" exec -i "${HELM_RELEASE}"-0 -- /bin/bash -c "/tmp/postgres_coverage.sh"

    # bring down helm install
    helm delete "${HELM_RELEASE}" --namespace "${NAMESPACE}"

    # delete the PVC associated
    kubectl -n "${NAMESPACE}" delete pvc --all

    # update image in docker-compose yml
    sed "s#@IMAGE#${IMAGE_REPOSITORY}:${TAG}#g" "${SCRIPTPATH}"/docker-compose.yml.base > "${SCRIPTPATH}"/docker-compose.yml

    # install container
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

declare -a BASE_TAG_ARRAY=("14.4.0-debian-11-r" "13.7.0-debian-11-r" "12.11.0-debian-11-r" "11.16.0-debian-11-r" "10.21.0-debian-11-r")

build_images "${INPUT_REGISTRY}" "${INPUT_ACCOUNT}" "${REPOSITORY}" "${REPOSITORY}" test "${PUBLISH_IMAGE}" "${BASE_TAG_ARRAY[@]}"

