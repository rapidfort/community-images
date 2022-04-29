#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
. ${SCRIPTPATH}/../../common/helpers.sh


BASE_TAG=8.0.29-debian-10-r
INPUT_REGISTRY=docker.io
INPUT_ACCOUNT=bitnami
REPOSITORY=mysql

test()
{
    local IMAGE_REPOSITORY=$1
    local TAG=$2
    local HELM_RELEASE=mysql-release
    
    echo "Testing mysql"

    # upgrade helm
    helm repo update

    # Install mysql
    helm install ${HELM_RELEASE} ${INPUT_ACCOUNT}/${REPOSITORY} --namespace ${NAMESPACE} --set image.tag=${TAG} --set image.repository=${IMAGE_REPOSITORY} -f ${SCRIPTPATH}/overrides.yml

    # waiting for pod to be ready
    echo "waiting for pod to be ready"
    kubectl wait pods ${HELM_RELEASE}-mysql-0 -n ${NAMESPACE} --for=condition=ready --timeout=10m

    # get mysql password
    MYSQL_ROOT_PASSWORD=$(kubectl get secret --namespace ${NAMESPACE} ${HELM_RELEASE}-mysql -o jsonpath="{.data.mysql-root-password}" | base64 --decode)

    # copy test.sql into container
    kubectl -n ${NAMESPACE} cp ${SCRIPTPATH}/../../common/tests/test.sql ${HELM_RELEASE}-mysql-0:/tmp/test.sql

    # run script
    kubectl -n ${NAMESPACE} exec -i ${HELM_RELEASE}-mysql-0 -- /bin/bash -c "mysql -h ${HELM_RELEASE}-mysql.${NAMESPACE}.svc.cluster.local -uroot -p\"$MYSQL_ROOT_PASSWORD\" < /tmp/test.sql"

    # bring down helm install
    helm delete ${HELM_RELEASE} --namespace ${NAMESPACE}

    # delete the PVC associated
    kubectl -n ${NAMESPACE} delete pvc --all
}

build_images ${INPUT_REGISTRY} ${INPUT_ACCOUNT} ${REPOSITORY} ${BASE_TAG} test
