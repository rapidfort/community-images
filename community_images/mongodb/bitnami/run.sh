#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
. ${SCRIPTPATH}/../../common/helpers.sh


BASE_TAG=5.0.8-debian-10-r
INPUT_REGISTRY=docker.io
INPUT_ACCOUNT=bitnami
REPOSITORY=mongodb

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
    local HELM_RELEASE=mongodb-release
    
    echo "Testing mongodb"

    # upgrade helm
    helm repo update

    # Install mongodb
    helm install ${HELM_RELEASE} ${INPUT_ACCOUNT}/${REPOSITORY} --namespace ${NAMESPACE} --set image.tag=${TAG} --set image.repository=${IMAGE_REPOSITORY} -f ${SCRIPTPATH}/overrides.yml

    # waiting for pod to be ready
    echo "waiting for pod to be ready"
    kubectl wait deployments ${HELM_RELEASE} -n ${NAMESPACE} --for=condition=Available=True --timeout=10m

    # get mongodb password
    MONGODB_ROOT_PASSWORD=$(kubectl get secret --namespace ${NAMESPACE} ${HELM_RELEASE} -o jsonpath="{.data.mongodb-root-password}" | base64 --decode)

    # get pod name
    POD_NAME=`kubectl -n ${NAMESPACE} get pods -l app.kubernetes.io/name=mongodb -o jsonpath="{.items[0].metadata.name}"`

    # copy common_commands.sh into container
    kubectl -n ${NAMESPACE} cp ${SCRIPTPATH}/../../common/tests/common_commands.sh ${POD_NAME}:/tmp/common_commands.sh

    # run command on cluster
    kubectl -n ${NAMESPACE} exec -i ${POD_NAME} -- /bin/bash -c "/tmp/common_commands.sh"

    # create MongoDB client
    envsubst < deployment.yaml | kubectl -n ${NAMESPACE} apply -f -

    # kubectl run -n ${NAMESPACE} ${HELM_RELEASE}-client \
    #     --restart='Never' \
    #     --env="MONGODB_ROOT_PASSWORD=${MONGODB_ROOT_PASSWORD}" \
    #     --image ${IMAGE_REPOSITORY}:${TAG} \
    #     --command -- /bin/bash -c "sleep infinity"

    # wait for mongodb client to be ready
    kubectl wait pods ${HELM_RELEASE}-client -n ${NAMESPACE} --for=condition=ready --timeout=10m

    # copy test.mongo into container
    kubectl -n ${NAMESPACE} cp ${SCRIPTPATH}/../../common/tests/test.mongo ${HELM_RELEASE}-client:/tmp/test.mongo

    # run script
    kubectl -n ${NAMESPACE} exec -i ${HELM_RELEASE}-client \
        -- /bin/bash -c "mongosh admin --host \"mongodb-release\" \
        --authenticationDatabase admin -u root -p ${MONGODB_ROOT_PASSWORD} --file /tmp/test.mongo"

    # delete client container
    kubectl -n ${NAMESPACE} delete pod ${HELM_RELEASE}-client

    # bring down helm install
    helm delete ${HELM_RELEASE} --namespace ${NAMESPACE}

    # delete the PVC associated
    kubectl -n ${NAMESPACE} delete pvc --all

    # update image in docker-compose yml
    sed "s#@IMAGE#${IMAGE_REPOSITORY}:${TAG}#g" ${SCRIPTPATH}/docker-compose.yml.base > ${SCRIPTPATH}/docker-compose.yml

    # install redis container
    docker-compose -f ${SCRIPTPATH}/docker-compose.yml -p ${NAMESPACE} up -d

    # sleep for 30 sec
    sleep 30

    # logs for tracking
    docker-compose -f ${SCRIPTPATH}/docker-compose.yml -p ${NAMESPACE} logs

    # kill docker-compose setup container
    docker-compose -f ${SCRIPTPATH}/docker-compose.yml -p ${NAMESPACE} down

    # clean up docker file
    rm -rf ${SCRIPTPATH}/docker-compose.yml
}

build_images ${INPUT_REGISTRY} ${INPUT_ACCOUNT} ${REPOSITORY} ${BASE_TAG} test ${PUBLISH_IMAGE}
