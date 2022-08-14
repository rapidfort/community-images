#!/bin/bash

set -x
set -e

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/helpers.sh


INPUT_REGISTRY=docker.io
INPUT_ACCOUNT=bitnami
REPOSITORY=prometheus

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
    #with_backoff helm install "${HELM_RELEASE}" "${INPUT_ACCOUNT}"/"${SP_REPO}" --namespace "${NAMESPACE}" --set prometheus.image.tag="${TAG}" --set prometheus.image.repository="${IMAGE_REPOSITORY}" -f "${SCRIPTPATH}"/overrides.yml
    kubectl run "${HELM_RELEASE}" --restart='Never' --image "${IMAGE_REPOSITORY}":"${TAG}" --namespace "${NAMESPACE}" --privileged
    # wait for prometheus pod to come up
    kubectl wait pods "${HELM_RELEASE}" -n "${NAMESPACE}" --for=condition=ready --timeout=10m
    report_pulls "${IMAGE_REPOSITORY}"

    # # waiting for pod to be ready
    # echo "waiting for pod to be ready"
    # kubectl wait deployments "${HELM_RELEASE}" -n "${NAMESPACE}" --for=condition=Available=True --timeout=10m

    # get pod name
    #POD_NAME=$(kubectl -n "${NAMESPACE}" get pods -l app.kubernetes.io/name="$REPOSITORY" -o jsonpath="{.items[0].metadata.name}")

    # copy common_commands.sh into container
    kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/../../common/tests/common_commands.sh "${HELM_RELEASE}":/tmp/common_commands.sh

    # run command on cluster
    kubectl -n "${NAMESPACE}" exec -i "${HELM_RELEASE}" -- /bin/bash -c "/tmp/common_commands.sh"

    PROMETHEUS_SERVER=$(kubectl get pod "${HELM_RELEASE}" -n "${NAMESPACE}" --template '{{.status.podIP}}')
    #PROMETHEUS_SERVER="${HELM_RELEASE}"."${NAMESPACE}".svc.cluster.local

    PROMETHEUS_PORT=9090

    test_prometheus "${NAMESPACE}" "${PROMETHEUS_SERVER}" "${PROMETHEUS_PORT}"

    # bring down helm install
    kubectl delete pod "${HELM_RELEASE}" --namespace "${NAMESPACE}"

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

declare -a BASE_TAG_ARRAY=("2.37.0-debian-11-r")
#declare -a BASE_TAG_ARRAY=("v2.37.")

build_images "${INPUT_REGISTRY}" "${INPUT_ACCOUNT}" "${REPOSITORY}" "${REPOSITORY}" test "${PUBLISH_IMAGE}" "${BASE_TAG_ARRAY[@]}"
