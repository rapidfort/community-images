#!/bin/bash

set -x
set -e

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/helpers.sh


INPUT_REGISTRY=docker.io
INPUT_ACCOUNT=bitnami
REPOSITORY=influxdb

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
    local HELM_RELEASE="$REPOSITORY"-release
    
    echo "Testing $REPOSITORY"

    # upgrade helm
    helm repo update

    # Install helm
    with_backoff helm install "${HELM_RELEASE}" "${INPUT_ACCOUNT}"/"${REPOSITORY}" --namespace "${NAMESPACE}" --set image.tag="${TAG}" --set image.repository="${IMAGE_REPOSITORY}" -f "${SCRIPTPATH}"/overrides.yml
    report_pulls "${IMAGE_REPOSITORY}"

    # waiting for pod to be ready
    echo "waiting for pod to be ready"
    kubectl wait deployments "${HELM_RELEASE}" -n "${NAMESPACE}" --for=condition=Available=True --timeout=10m

    # get pod name
    POD_NAME=$(kubectl -n "${NAMESPACE}" get pods -l app.kubernetes.io/name="$REPOSITORY" -o jsonpath="{.items[0].metadata.name}")

    # copy common_commands.sh into container
    kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/../../common/tests/common_commands.sh "${POD_NAME}":/tmp/common_commands.sh

    # run command on cluster
    kubectl -n "${NAMESPACE}" exec -i "${POD_NAME}" -- /bin/bash -c "/tmp/common_commands.sh"

    # copy tests into container
    kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/tests/example.csv "${POD_NAME}":/tmp/example.csv
    kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/tests/query.flux "${POD_NAME}":/tmp/query.flux

    # run tests on cluster
    kubectl -n "${NAMESPACE}" exec -i "${POD_NAME}" -- influx write -b example-bucket -f /tmp/example.csv

    # # create MongoDB client
    # MONGODB_ROOT_PASSWORD="${MONGODB_ROOT_PASSWORD}" \
    #     IMAGE_REPOSITORY="${IMAGE_REPOSITORY}" \
    #     TAG="${TAG}" envsubst < "${SCRIPTPATH}"/client.yml.base | kubectl -n "${NAMESPACE}" apply -f -

    # # wait for mongodb client to be ready
    # kubectl wait pods "${HELM_RELEASE}"-client -n "${NAMESPACE}" --for=condition=ready --timeout=10m

    # # copy test.mongo into container
    # kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/../../common/tests/test.mongo "${HELM_RELEASE}"-client:/tmp/test.mongo

    # # run script
    # kubectl -n "${NAMESPACE}" exec -i "${HELM_RELEASE}"-client \
    #     -- /bin/bash -c "mongosh admin --host \"mongodb-release\" \
    #     --authenticationDatabase admin -u root -p ${MONGODB_ROOT_PASSWORD} --file /tmp/test.mongo"

    # # delete client container
    # kubectl -n "${NAMESPACE}" delete pod "${HELM_RELEASE}"-client

    # bring down helm install
    helm delete "${HELM_RELEASE}" --namespace "${NAMESPACE}"

    # delete the PVC associated
    kubectl -n "${NAMESPACE}" delete pvc --all

    # update image in docker-compose yml
    sed "s#@IMAGE#${IMAGE_REPOSITORY}:${TAG}#g" "${SCRIPTPATH}"/docker-compose.yml.base > "${SCRIPTPATH}"/docker-compose.yml

    # install docker container
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

declare -a BASE_TAG_ARRAY=("2.3.0-debian-11-r")

build_images "${INPUT_REGISTRY}" "${INPUT_ACCOUNT}" "${REPOSITORY}" test "${PUBLISH_IMAGE}" "${BASE_TAG_ARRAY[@]}"
