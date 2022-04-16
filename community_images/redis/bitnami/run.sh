#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
. ${SCRIPTPATH}/../../common/helpers.sh


BASE_TAG=6.2.6-debian-10-r
INPUT_REGISTRY=docker.io
INPUT_ACCOUNT=bitnami
REPOSITORY=redis


test_no_tls()
{
    local IMAGE_REPOSITORY=$1
    local TAG=$2
    local HELM_RELEASE=redis-release

    echo "Testing redis without TLS"

    # upgrade helm
    helm repo update

    # Install redis
    helm install ${HELM_RELEASE}  ${INPUT_ACCOUNT}/${REPOSITORY} --namespace ${NAMESPACE} --set image.tag=${TAG} --set image.repository=${IMAGE_REPOSITORY} -f ${SCRIPTPATH}/overrides.yml

    # waiting for pod to be ready
    echo "waiting for pod to be ready"
    kubectl wait pods ${HELM_RELEASE}-master-0 -n ${NAMESPACE} --for=condition=ready --timeout=5m

    # get Redis passwordk
    REDIS_PASSWORD=$(kubectl get secret --namespace ${NAMESPACE} ${HELM_RELEASE} -o jsonpath="{.data.redis-password}" | base64 --decode)

    # copy test.redis into container
    kubectl -n ${NAMESPACE} cp ${SCRIPTPATH}/../../common/tests/test.redis ${HELM_RELEASE}-master-0:/tmp/test.redis

    # run script
    kubectl -n ${NAMESPACE} exec -i ${HELM_RELEASE}-master-0 -- /bin/bash -c "cat /tmp/test.redis | REDISCLI_AUTH=\"${REDIS_PASSWORD}\" redis-cli -h localhost --pipe"

    # bring down helm install
    helm delete ${HELM_RELEASE} --namespace ${NAMESPACE}

    # delete the PVC associated
    kubectl -n ${NAMESPACE} delete pvc redis-data-${HELM_RELEASE}-master-0
    kubectl -n ${NAMESPACE} delete pvc redis-data-${HELM_RELEASE}-replicas-0
    kubectl -n ${NAMESPACE} delete pvc redis-data-${HELM_RELEASE}-replicas-1
    kubectl -n ${NAMESPACE} delete pvc redis-data-${HELM_RELEASE}-replicas-2
}


test_tls()
{
    local IMAGE_REPOSITORY=$1
    local TAG=$2
    local HELM_RELEASE=redis-release
    echo "Testing redis with TLS"

    # Install certs
    kubectl apply -f ${SCRIPTPATH}/tls_certs.yml

    # upgrade helm
    helm repo update

    # Install redis
    helm install ${HELM_RELEASE} ${INPUT_ACCOUNT}/${REPOSITORY} --namespace ${NAMESPACE} --set image.tag=${TAG} --set image.repository=${IMAGE_REPOSITORY} --set tls.enabled=true --set tls.existingSecret=localhost-server-tls --set tls.certCAFilename=ca.crt --set tls.certFilename=tls.crt --set tls.certKeyFilename=tls.key -f ${SCRIPTPATH}/overrides.yml

    # waiting for pod to be ready
    echo "waiting for pod to be ready"
    kubectl wait pods ${HELM_RELEASE}-master-0 -n ${NAMESPACE} --for=condition=ready --timeout=5m

    # get Redis passwordk
    REDIS_PASSWORD=$(kubectl get secret --namespace ${NAMESPACE} ${HELM_RELEASE} -o jsonpath="{.data.redis-password}" | base64 --decode)

    # copy test.redis into container
    kubectl -n ${NAMESPACE} cp ${SCRIPTPATH}/../../common/tests/test.redis ${HELM_RELEASE}-master-0:/tmp/test.redis

    # run script
    kubectl -n ${NAMESPACE} exec -i ${HELM_RELEASE}-master-0 -- /bin/bash -c "cat /tmp/test.redis | REDISCLI_AUTH=\"${REDIS_PASSWORD}\" redis-cli -h localhost --tls --cert /opt/bitnami/redis/certs/tls.crt --key /opt/bitnami/redis/certs/tls.key --cacert /opt/bitnami/redis/certs/ca.crt --pipe"

    # bring down helm install
    helm delete ${HELM_RELEASE} --namespace ${NAMESPACE}

    # delete certs
    kubectl delete -f ${SCRIPTPATH}/tls_certs.yml

    # delete the PVC associated
    kubectl -n ${NAMESPACE} delete pvc redis-data-${HELM_RELEASE}-master-0
    kubectl -n ${NAMESPACE} delete pvc redis-data-${HELM_RELEASE}-replicas-0
    kubectl -n ${NAMESPACE} delete pvc redis-data-${HELM_RELEASE}-replicas-1
    kubectl -n ${NAMESPACE} delete pvc redis-data-${HELM_RELEASE}-replicas-2

}


build_images ${INPUT_REGISTRY} ${INPUT_ACCOUNT} ${REPOSITORY} ${BASE_TAG} test_no_tls
build_images ${INPUT_REGISTRY} ${INPUT_ACCOUNT} ${REPOSITORY} ${BASE_TAG} test_tls
