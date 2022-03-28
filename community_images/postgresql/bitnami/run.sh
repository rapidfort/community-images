#!/bin/bash

set -x

. ../../common/helpers.sh


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
    helm install ${HELM_RELEASE} ${INPUT_ACCOUNT}/${REPOSITORY} --namespace ${NAMESPACE} --set image.tag=${TAG} --set image.repository=${IMAGE_REPOSITORY} -f overrides.yml

    # sleep for 1 min
    echo "waiting for 1 min for setup"
    sleep 1m

    # get postgresql passwordk
    POSTGRES_PASSWORD=$(kubectl get secret --namespace ${NAMESPACE} ${HELM_RELEASE} -o jsonpath="{.data.postgres-password}" | base64 --decode)

    # copy test.sql into container
    kubectl -n ${NAMESPACE} cp test.sql ${HELM_RELEASE}-0:/tmp/test.sql

    # exec into container
    kubectl -n ${NAMESPACE} exec -it ${HELM_RELEASE}-0 -- /bin/bash -c "PGPASSWORD=${POSTGRES_PASSWORD} psql --host ${HELM_RELEASE} -U postgres -d postgres -p 5432 -f /tmp/test.sql"

    # sleep for 30 sec
    echo "waiting for 30 sec"
    sleep 30

    # bring down helm install
    helm delete ${HELM_RELEASE} --namespace ${NAMESPACE}

    # delete the PVC associated
    kubectl -n ${NAMESPACE} delete pvc data-${HELM_RELEASE}-0

    # sleep for 30 sec
    echo "waiting for 30 sec"
    sleep 30
}

build_images ${INPUT_REGISTRY} ${INPUT_ACCOUNT} ${REPOSITORY} ${BASE_TAG} test
