#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/helpers.sh

INPUT_REGISTRY=docker.io
INPUT_ACCOUNT=bitnami
REPOSITORY=redis

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
    local HELM_RELEASE=redis-release

    echo "Testing redis without TLS"

    # upgrade helm
    helm repo update

    # Install redis
    helm install "${HELM_RELEASE}"  ${INPUT_ACCOUNT}/${REPOSITORY} --namespace "${NAMESPACE}" --set image.tag="${TAG}" --set image.repository="${IMAGE_REPOSITORY}" -f "${SCRIPTPATH}"/overrides.yml

    # waiting for pod to be ready
    echo "waiting for pod to be ready"
    kubectl wait pods "${HELM_RELEASE}"-master-0 -n "${NAMESPACE}" --for=condition=ready --timeout=10m

    # get Redis passwordk
    REDIS_PASSWORD=$(kubectl get secret --namespace "${NAMESPACE}" "${HELM_RELEASE}" -o jsonpath="{.data.redis-password}" | base64 --decode)

    # copy test.redis into container
    kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/../../common/tests/test.redis "${HELM_RELEASE}"-master-0:/tmp/test.redis

    # run script
    kubectl -n "${NAMESPACE}" exec -i "${HELM_RELEASE}"-master-0 -- /bin/bash -c "cat /tmp/test.redis | REDISCLI_AUTH=\"${REDIS_PASSWORD}\" redis-cli -h localhost --pipe"

    # bring down helm install
    helm delete "${HELM_RELEASE}" --namespace "${NAMESPACE}"

    # delete the PVC associated
    kubectl -n "${NAMESPACE}" delete pvc --all

    echo "Testing redis with TLS"

    # Install certs
    kubectl apply -f "${SCRIPTPATH}"/tls_certs.yml --namespace "${NAMESPACE}"

    # Install redis with tls
    helm install "${HELM_RELEASE}" "${INPUT_ACCOUNT}"/"${REPOSITORY}" --namespace "${NAMESPACE}" --set image.tag="${TAG}" --set image.repository="${IMAGE_REPOSITORY}" --set tls.enabled=true --set tls.existingSecret=localhost-server-tls --set tls.certCAFilename=ca.crt --set tls.certFilename=tls.crt --set tls.certKeyFilename=tls.key -f "${SCRIPTPATH}"/overrides.yml

    # waiting for pod to be ready
    echo "waiting for pod to be ready"
    kubectl wait pods "${HELM_RELEASE}"-master-0 -n "${NAMESPACE}" --for=condition=ready --timeout=10m

    # get Redis passwordk
    REDIS_PASSWORD=$(kubectl get secret --namespace "${NAMESPACE}" "${HELM_RELEASE}" -o jsonpath="{.data.redis-password}" | base64 --decode)

    # copy test.redis into container
    kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/../../common/tests/test.redis "${HELM_RELEASE}"-master-0:/tmp/test.redis

    # run script
    kubectl -n "${NAMESPACE}" exec -i "${HELM_RELEASE}"-master-0 -- /bin/bash -c "cat /tmp/test.redis | REDISCLI_AUTH=\"${REDIS_PASSWORD}\" redis-cli -h localhost --tls --cert /opt/bitnami/redis/certs/tls.crt --key /opt/bitnami/redis/certs/tls.key --cacert /opt/bitnami/redis/certs/ca.crt --pipe"

    # copy common_commands.sh into container
    kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/../../common/tests/common_commands.sh "${HELM_RELEASE}"-master-0:/tmp/common_commands.sh

    # run command on cluster
    kubectl -n "${NAMESPACE}" exec -i "${HELM_RELEASE}"-master-0 -- /bin/bash -c "/tmp/common_commands.sh"

    # copy redis_coverage.sh into container
    kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/../../common/tests/redis_coverage.sh "${HELM_RELEASE}"-master-0:/tmp/redis_coverage.sh

    # run command on cluster
    kubectl -n "${NAMESPACE}" exec -i "${HELM_RELEASE}"-master-0 -- /bin/bash -c "/tmp/redis_coverage.sh"

    # bring down helm install
    helm delete "${HELM_RELEASE}" --namespace "${NAMESPACE}"

    # delete certs
    kubectl delete -f "${SCRIPTPATH}"/tls_certs.yml --namespace "${NAMESPACE}"

    # delete the PVC associated
    kubectl -n "${NAMESPACE}" delete pvc --all

    # install redis container
    docker run --rm -d -p 6379:6379 --cap-add=SYS_PTRACE -e "REDIS_PASSWORD=${REDIS_PASSWORD}" --name "${NAMESPACE}" "${IMAGE_REPOSITORY}":"${TAG}"

    # sleep for 30 sec
    sleep 30

    # kill docker container
    docker kill "${NAMESPACE}"

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

declare -a BASE_TAG_ARRAY=("6.2.7-debian-10-r" "6.0.16-debian-10-r")

build_images "${INPUT_REGISTRY}" "${INPUT_ACCOUNT}" "${REPOSITORY}" test "${PUBLISH_IMAGE}" "${BASE_TAG_ARRAY[@]}"
