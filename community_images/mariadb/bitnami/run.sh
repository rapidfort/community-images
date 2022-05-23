#!/bin/bash

set -x
set -e

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/helpers.sh


INPUT_REGISTRY=docker.io
INPUT_ACCOUNT=bitnami
REPOSITORY=mariadb

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
    local HELM_RELEASE=mariadb-release
    
    echo "Testing mariadb"

    # upgrade helm
    helm repo update

    # Install mariadb
    helm install "${HELM_RELEASE}" "${INPUT_ACCOUNT}"/"${REPOSITORY}" --namespace "${NAMESPACE}" --set image.tag="${TAG}" --set image.repository="${IMAGE_REPOSITORY}" -f "${SCRIPTPATH}"/overrides.yml

    # waiting for pod to be ready
    echo "waiting for pod to be ready"
    kubectl wait pods "${HELM_RELEASE}"-0 -n "${NAMESPACE}" --for=condition=ready --timeout=10m

    # get mariadb password
    MARIADB_ROOT_PASSWORD=$(kubectl get secret --namespace "${NAMESPACE}" "${HELM_RELEASE}" -o jsonpath="{.data.mariadb-root-password}" | base64 --decode)

    # copy test.sql into container
    kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/../../common/tests/test.my_sql "${HELM_RELEASE}"-0:/tmp/test.my_sql

    # run script
    kubectl -n "${NAMESPACE}" exec -i "${HELM_RELEASE}"-0 -- /bin/bash -c "mysql -h localhost -uroot -p\"$MARIADB_ROOT_PASSWORD\" mysql < /tmp/test.my_sql"

    # copy common_commands.sh into container
    kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/../../common/tests/common_commands.sh ${HELM_RELEASE}-0:/tmp/common_commands.sh

    # run command on cluster
    kubectl -n "${NAMESPACE}" exec -i "${HELM_RELEASE}"-0 -- /bin/bash -c "/tmp/common_commands.sh"

    # copy mysql_coverage.sh into container
    kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/../../common/tests/mysql_coverage.sh ${HELM_RELEASE}-0:/tmp/mysql_coverage.sh

    # run mysql_coverage on cluster
    kubectl -n "${NAMESPACE}" exec -i "${HELM_RELEASE}"-0 -- /bin/bash -c "/tmp/mysql_coverage.sh"

    # bring down helm install
    helm delete "${HELM_RELEASE}" --namespace "${NAMESPACE}"

    # delete the PVC associated
    kubectl -n "${NAMESPACE}" delete pvc --all

    # update image in docker-compose yml
    sed "s#@IMAGE#${IMAGE_REPOSITORY}:${TAG}#g" "${SCRIPTPATH}"/docker-compose.yml.base > "${SCRIPTPATH}"/docker-compose.yml

    # install redis container
    docker-compose -f "${SCRIPTPATH}"/docker-compose.yml -p "${NAMESPACE}" up -d

    # sleep for 30 sec
    sleep 30

    # logs for tracking
    docker-compose -f "${SCRIPTPATH}"/docker-compose.yml -p "${NAMESPACE}" logs

    # kill docker-compose setup container
    docker-compose -f "${SCRIPTPATH}"/docker-compose.yml -p "${NAMESPACE}" down

    # clean up docker file
    rm -rf "${SCRIPTPATH}"/docker-compose.yml
}

declare -a BASE_TAG_ARRAY=("10.7.4-debian-10-r" "10.6.8-debian-10-r" "10.5.16-debian-10-r" "10.4.25-debian-10-r" "10.3.35-debian-10-r" "10.2.44-debian-10-r")

build_images "${INPUT_REGISTRY}" "${INPUT_ACCOUNT}" "${REPOSITORY}" "${BASE_TAG_ARRAY[@]}" test "${PUBLISH_IMAGE}"
