#!/bin/bash

set -x
set -e

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/bash_helper.sh

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/coverage.sh

INPUT_ACCOUNT=bitnami
REPOSITORY=nats
HELM_RELEASE="$REPOSITORY"-release

run_coverage()
{
    local NAMESPACE=$1
    shift
    shift # we dont need number of images, hence shift

    local IMAGE_TAG_ARRAY=( "$@" )

    local IMAGE_REPOSITORY="${IMAGE_TAG_ARRAY[0]}"
    local TAG="${IMAGE_TAG_ARRAY[1]}"
    
    echo "Testing $REPOSITORY"

    # upgrade helm
    helm repo update

    # Install helm
    with_backoff helm install "${HELM_RELEASE}" "${INPUT_ACCOUNT}"/"${REPOSITORY}" --namespace "${NAMESPACE}" --set image.tag="${TAG}" --set image.repository="${IMAGE_REPOSITORY}" -f "${SCRIPTPATH}"/overrides.yml
    
    # waiting for pod to be ready
    echo "waiting for pod to be ready"
    kubectl wait deployments "${HELM_RELEASE}" -n "${NAMESPACE}" --for=condition=Available=True --timeout=10m

    # get pod name
    POD_NAME=$(kubectl -n "${NAMESPACE}" get pods -l app.kubernetes.io/name="$REPOSITORY" -o jsonpath="{.items[0].metadata.name}")

    # copy common_commands.sh into container
    kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/../../common/tests/common_commands.sh "${POD_NAME}":/tmp/common_commands.sh

    # run command on cluster
    kubectl -n "${NAMESPACE}" exec -i "${POD_NAME}" -- /bin/bash -c "/tmp/common_commands.sh"

    # run coverage script
    test_nats "${NAMESPACE}" "${HELM_RELEASE}"

    # log pods
    kubectl -n "${NAMESPACE}" get pods
    kubectl -n "${NAMESPACE}" get svc

    # bring down helm install
    helm delete "${HELM_RELEASE}" --namespace "${NAMESPACE}"

    # delete the PVC associated
    kubectl -n "${NAMESPACE}" delete pvc --all
}

NAMESPACE="$1"
shift
NUMBER_OF_IMAGES="$2"
shift

run_coverage "${NAMESPACE}" "${NUMBER_OF_IMAGES}" "$@"
