#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
. ${SCRIPTPATH}/../../common/helpers.sh


BASE_TAG=14.1.0-debian-10-r
INPUT_REGISTRY=docker.io
INPUT_ACCOUNT=bitnami
REPOSITORY=postgresql

test()
{
    local IMAGE_REPOSITORY=$1
    local TAG=$2
    local HELM_RELEASE=postgresql-release
    
    echo "Testing postgresql"
    # Install postgresql
    helm install ${HELM_RELEASE} ${INPUT_ACCOUNT}/${REPOSITORY} --namespace ${NAMESPACE} --set image.tag=${TAG} --set image.repository=${IMAGE_REPOSITORY} -f ${SCRIPTPATH}/overrides.yml

    # waiting for pod to be ready
    echo "waiting for pod to be ready"
    kubectl wait pods ${HELM_RELEASE}-0 -n ${NAMESPACE} --for=condition=ready --timeout=5m

    # get postgresql passwordk
    POSTGRES_PASSWORD=$(kubectl get secret --namespace ${NAMESPACE} ${HELM_RELEASE} -o jsonpath="{.data.postgres-password}" | base64 --decode)

    # copy test.sql into container
    kubectl -n ${NAMESPACE} cp ${SCRIPTPATH}/test.sql ${HELM_RELEASE}-0:/tmp/test.sql

    # exec into container
    kubectl -n ${NAMESPACE} exec -it ${HELM_RELEASE}-0 -- /bin/bash -c "PGPASSWORD=${POSTGRES_PASSWORD} psql --host ${HELM_RELEASE} -U postgres -d postgres -p 5432 -f /tmp/test.sql"

    # bring down helm install
    helm delete ${HELM_RELEASE} --namespace ${NAMESPACE}

    # delete the PVC associated
    kubectl -n ${NAMESPACE} delete pvc data-${HELM_RELEASE}-0
}

build_images ${INPUT_REGISTRY} ${INPUT_ACCOUNT} ${REPOSITORY} ${BASE_TAG} test
