#!/bin/bash

set -x
set -e

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/helpers.sh


INPUT_REGISTRY=docker.io
INPUT_ACCOUNT=bitnami
REPOSITORY=apache

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

    # fetch service url and store the urls in URLS file
    rm -f URLS
    minikube service "${HELM_RELEASE}" -n "${NAMESPACE}" --url >> URLS

    # create ssl certs
    cleanup_certs
    create_certs

    # Changing "http" to "https" in the urls file
    sed -i '2,2s/http/https/' URLS
    cat URLS

    # curl to urls
    while read p;
    do
        curl -k "${p}"
    done <URLS

    #Removing urls file
    rm URLS

    # fetch minikube ip
    MINIKUBE_IP=$(minikube ip)

    # curl to https url
    curl http://"${MINIKUBE_IP}" -k

    # copy common_commands.sh into container
    kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/../../common/tests/common_commands.sh "${POD_NAME}":/tmp/common_commands.sh

    # run command on cluster
    kubectl -n "${NAMESPACE}" exec -i "${POD_NAME}" -c apache -- /bin/bash -c "/tmp/common_commands.sh"

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

    # exec into container and run coverage script
    pwd
    chmod 777 "${SCRIPTPATH}"/coverage_script.sh
    docker exec -i "${NAMESPACE}"-apache-1 bash -c /opt/bitnami/scripts/coverage_script.sh

    # log for debugging
    docker inspect "${NAMESPACE}"-apache-1

    # find non-tls and tls port
    NON_TLS_PORT=$(docker inspect "${NAMESPACE}"-apache-1 | jq -r ".[].NetworkSettings.Ports.\"8080/tcp\"[0].HostPort")
    TLS_PORT=$(docker inspect "${NAMESPACE}"-apache-1 | jq -r ".[].NetworkSettings.Ports.\"8443/tcp\"[0].HostPort")

    echo "${NON_TLS_PORT}"
    echo "${TLS_PORT}"

    # run curl in loop for different endpoints
    for i in {1..20};
    do
        echo "$i"
        curl http://localhost:"${NON_TLS_PORT}"
        with_backoff curl https://localhost:"${TLS_PORT}" -k -v
    done

    # logs for tracking
    docker-compose -f "${SCRIPTPATH}"/docker-compose.yml -p "${NAMESPACE}" logs

    # kill docker-compose setup container
    docker-compose -f "${SCRIPTPATH}"/docker-compose.yml -p "${NAMESPACE}" down

    # clean up docker file
    rm -rf "${SCRIPTPATH}"/docker-compose.yml

    # clean up certs
    cleanup_certs
}

declare -a BASE_TAG_ARRAY=("2.4.54-debian-11-r" "2.4.53-debian-10-r")

build_images "${INPUT_REGISTRY}" "${INPUT_ACCOUNT}" "${REPOSITORY}" test "${PUBLISH_IMAGE}" "${BASE_TAG_ARRAY[@]}"
