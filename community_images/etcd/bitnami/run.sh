#!/bin/bash

set -x
set -e

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/helpers.sh


INPUT_REGISTRY=docker.io
INPUT_ACCOUNT=bitnami
REPOSITORY=etcd

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

    # wait for pods
    kubectl wait pods "${HELM_RELEASE}"-0 -n "${NAMESPACE}" --for=condition=ready --timeout=10m

    # get pod name
    POD_NAME="${HELM_RELEASE}"-0

    # etcd password
    ROOT_PASSWORD=$(kubectl get secret --namespace "${NAMESPACE}" etcd-release -o jsonpath="{.data.etcd-root-password}" | base64 -d)

    # copy etcd_test.sh into container
    kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/etcd_test.sh "${POD_NAME}":/tmp/etcd_test.sh

    # run etcd_test on cluster
    kubectl -n "${NAMESPACE}" exec -i "${POD_NAME}" -- /bin/bash -c "/tmp/etcd_test.sh $ROOT_PASSWORD"

    # copy common_commands.sh into container
    kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/../../common/tests/common_commands.sh "${POD_NAME}":/tmp/common_commands.sh

    # run command on cluster
    kubectl -n "${NAMESPACE}" exec -i "${POD_NAME}" -- /bin/bash -c "/tmp/common_commands.sh"

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

declare -a BASE_TAG_ARRAY=("3.5.4-debian-11-r" "3.4.18-debian-11-r" "3.3.27-debian-11-r")

build_images "${INPUT_REGISTRY}" "${INPUT_ACCOUNT}" "${REPOSITORY}" test "${PUBLISH_IMAGE}" "${BASE_TAG_ARRAY[@]}"
