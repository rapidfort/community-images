#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/helpers.sh

REPOSITORY=nginx
HELM_RELEASE=rf-"${REPOSITORY}"
NAMESPACE=$(get_namespace_string "${HELM_RELEASE}")

k8s_test()
{
    # setup namespace
    setup_namespace "${NAMESPACE}"

    # install helm
    with_backoff helm install "${HELM_RELEASE}" \
        bitnami/"$REPOSITORY" \
        --set image.repository=rapidfort/"$REPOSITORY" \
        --set cloneStaticSiteFromGit.enabled=true \
        --set cloneStaticSiteFromGit.repository="https://github.com/mdn/beginner-html-site-styled.git" \
        --set cloneStaticSiteFromGit.branch=master \
        --namespace "${NAMESPACE}"

    # waiting for pod to be ready
    echo "waiting for pod to be ready"
    kubectl wait deployments "${HELM_RELEASE}" -n "${NAMESPACE}" --for=condition=Available=True --timeout=10m

    # fetch service url and curl to url
    URL=$(minikube service "${HELM_RELEASE}" -n "${NAMESPACE}" --url)

    # curl to http url
    curl -k "${URL}"


    # log pods
    kubectl -n "${NAMESPACE}" get pods
    kubectl -n "${NAMESPACE}" get svc

    # delte cluster
    helm delete "${HELM_RELEASE}" --namespace "${NAMESPACE}"

    # delete pvc
    kubectl -n "${NAMESPACE}" delete pvc --all

    # clean up namespace
    cleanup_namespace "${NAMESPACE}"
}

docker_test()
{
    # create network
    docker network create -d bridge "${NAMESPACE}"

    # create docker container
    docker run --rm -d --network="${NAMESPACE}" \
        --name "${NAMESPACE}" rapidfort/"$REPOSITORY":latest

    # sleep for few seconds
    sleep 30

    # clean up docker container
    docker kill "${NAMESPACE}"

    # delete network
    docker network rm "${NAMESPACE}"
}

docker_compose_test()
{
    # update image in docker-compose yml
    sed "s#@IMAGE#rapidfort/$REPOSITORY#g" "${SCRIPTPATH}"/docker-compose.yml.base > "${SCRIPTPATH}"/docker-compose.yml

    # install postgresql container
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

main()
{
    k8s_test
    docker_test
    docker_compose_test
}

main