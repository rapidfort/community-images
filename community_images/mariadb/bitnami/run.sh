#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
. ${SCRIPTPATH}/../../common/helpers.sh


BASE_TAG=10.6.7-debian-10-r
INPUT_REGISTRY=docker.io
INPUT_ACCOUNT=bitnami
REPOSITORY=mariadb

test()
{
    local IMAGE_REPOSITORY=$1
    local TAG=$2
    local HELM_RELEASE=mariadb-release
    
    echo "Testing mariadb"

    # upgrade helm
    helm repo update

    # Install mariadb
    helm install ${HELM_RELEASE} ${INPUT_ACCOUNT}/${REPOSITORY} --namespace ${NAMESPACE} --set image.tag=${TAG} --set image.repository=${IMAGE_REPOSITORY} -f ${SCRIPTPATH}/overrides.yml

    # waiting for pod to be ready
    echo "waiting for pod to be ready"
    kubectl wait pods ${HELM_RELEASE}-0 -n ${NAMESPACE} --for=condition=ready --timeout=10m

    # get mariadb password
    MARIADB_ROOT_PASSWORD=$(kubectl get secret --namespace ${NAMESPACE} ${HELM_RELEASE} -o jsonpath="{.data.mariadb-root-password}" | base64 --decode)

    # copy test.sql into container
    kubectl -n ${NAMESPACE} cp ${SCRIPTPATH}/../../common/tests/test.my_sql ${HELM_RELEASE}-0:/tmp/test.my_sql

    # run script
    kubectl -n ${NAMESPACE} exec -i ${HELM_RELEASE}-0 -- /bin/bash -c "mysql -h ${HELM_RELEASE}.${NAMESPACE}.svc.cluster.local -uroot -p\"$MARIADB_ROOT_PASSWORD\" mysql < /tmp/test.my_sql"

    # bring down helm install
    helm delete ${HELM_RELEASE} --namespace ${NAMESPACE}

    # delete the PVC associated
    kubectl -n ${NAMESPACE} delete pvc --all
}

build_images ${INPUT_REGISTRY} ${INPUT_ACCOUNT} ${REPOSITORY} ${BASE_TAG} test
