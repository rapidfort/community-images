#!/bin/bash

set -x

. ../../common/helpers.sh


TAG=$1
INPUT_REGISTRY=docker.io
INPUT_ACCOUNT=bitnami
REPOSITORY=redis-cluster


test_no_tls()
{
    local IMAGE_REPOSITORY=$1
    local HELM_RELEASE=redis-cluster-release

    echo "Testing redis without TLS"
    # Install redis
    helm install ${HELM_RELEASE}  ${INPUT_ACCOUNT}/${REPOSITORY} --namespace ${NAMESPACE} --set image.tag=${TAG} --set redis.livenessProbe.enabled=false --set image.repository=${IMAGE_REPOSITORY} -f overrides.yml
    # disabled liveness check due to https://github.com/bitnami/charts/issues/8978

    # sleep for 2 min
    echo "waiting for 2 min for setup"
    sleep 2m

    # get Redis passwordk
    REDIS_PASSWORD=$(kubectl get secret --namespace ${NAMESPACE} ${HELM_RELEASE} -o jsonpath="{.data.redis-password}" | base64 --decode)

    # exec into container
    kubectl -n ${NAMESPACE} exec -it ${HELM_RELEASE}-0 -- /bin/bash -c "REDISCLI_AUTH=${REDIS_PASSWORD} redis-cli -h ${HELM_RELEASE} -c EVAL \"return {KEYS[1],KEYS[2],ARGV[1],ARGV[2]}\" 2 {user1}:key1 {user1}:key2 first second"

    # sleep for 30 sec
    echo "waiting for 30 sec"
    sleep 30

    # bring down helm install
    helm delete ${HELM_RELEASE} --namespace ${NAMESPACE}

    # delete the PVC associated
    kubectl -n ${NAMESPACE} delete pvc redis-data-${HELM_RELEASE}-0
    kubectl -n ${NAMESPACE} delete pvc redis-data-${HELM_RELEASE}-1
    kubectl -n ${NAMESPACE} delete pvc redis-data-${HELM_RELEASE}-2
    kubectl -n ${NAMESPACE} delete pvc redis-data-${HELM_RELEASE}-3
    kubectl -n ${NAMESPACE} delete pvc redis-data-${HELM_RELEASE}-4
    kubectl -n ${NAMESPACE} delete pvc redis-data-${HELM_RELEASE}-5

    # sleep for 30 sec
    echo "waiting for 30 sec"
    sleep 30
}


test_tls()
{
    local IMAGE_REPOSITORY=$1
    local HELM_RELEASE=redis-cluster-release

    echo "Testing redis with TLS"

    # Install certs
    kubectl apply -f tls_certs.yml

    # sleep 1 min
    echo "waiting for 1 min for setup"
    sleep 1m

    # Install redis
    helm install ${HELM_RELEASE} ${INPUT_ACCOUNT}/${REPOSITORY} --namespace ${NAMESPACE} --set image.tag=${TAG} --set image.repository=${IMAGE_REPOSITORY} --set tls.enabled=true --set tls.existingSecret=${HELM_RELEASE}-tls --set tls.certCAFilename=ca.crt --set tls.certFilename=tls.crt --set tls.certKeyFilename=tls.key --set redis.livenessProbe.enabled=false -f overrides.yml
    # disabled liveness check due to https://github.com/bitnami/charts/issues/8978

    # sleep for 2 min
    echo "waiting for 2 min for setup"
    sleep 2m

    # get Redis passwordk
    REDIS_PASSWORD=$(kubectl get secret --namespace ${NAMESPACE} ${HELM_RELEASE} -o jsonpath="{.data.redis-password}" | base64 --decode)

    # exec into container
    kubectl -n ${NAMESPACE} exec -it ${HELM_RELEASE}-0 -- /bin/bash -c "REDISCLI_AUTH=\"${REDIS_PASSWORD}\" redis-cli -h ${HELM_RELEASE} --tls --cert /opt/bitnami/redis/certs/tls.crt --key /opt/bitnami/redis/certs/tls.key --cacert /opt/bitnami/redis/certs/ca.crt -c EVAL \"return {KEYS[1],KEYS[2],ARGV[1],ARGV[2]}\" 2 {user1}:key1 {user1}:key2 first second"

    # sleep for 30 sec
    echo "waiting for 30 sec"
    sleep 30

    # bring down helm install
    helm delete ${HELM_RELEASE} --namespace ${NAMESPACE}

    # delete certs
    kubectl delete -f tls_certs.yml

    # delete the PVC associated
    kubectl -n ${NAMESPACE} delete pvc redis-data-${HELM_RELEASE}-0
    kubectl -n ${NAMESPACE} delete pvc redis-data-${HELM_RELEASE}-1
    kubectl -n ${NAMESPACE} delete pvc redis-data-${HELM_RELEASE}-2
    kubectl -n ${NAMESPACE} delete pvc redis-data-${HELM_RELEASE}-3
    kubectl -n ${NAMESPACE} delete pvc redis-data-${HELM_RELEASE}-4
    kubectl -n ${NAMESPACE} delete pvc redis-data-${HELM_RELEASE}-5

    # sleep for 30 sec
    echo "waiting for 30 sec"
    sleep 30
}

build_images ${INPUT_REGISTRY} ${INPUT_ACCOUNT} ${REPOSITORY} ${TAG} test_no_tls
build_images ${INPUT_REGISTRY} ${INPUT_ACCOUNT} ${REPOSITORY} ${TAG} test_tls
