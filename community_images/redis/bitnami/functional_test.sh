#!/bin/bash

set -x
set -e

HELM_RELEASE=rf-redis
NAMESPACE=ci-test

test()
{
    # install redis
    helm install ${HELM_RELEASE} bitnami/redis --set image.repository=rapidfort/redis --namespace ${NAMESPACE}
    
    # wait for redis
    kubectl wait pods ${HELM_RELEASE}-master-0 -n ${NAMESPACE} --for=condition=ready --timeout=10m
    
    # for logs dump pods
    kubectl -n ${NAMESPACE} get pods

    # get password
    REDIS_PASSWORD=$(kubectl get secret --namespace ${NAMESPACE} ${HELM_RELEASE} -o jsonpath="{.data.redis-password}" | base64 --decode)
    
    # run redis-client
    kubectl run --namespace ${NAMESPACE} redis-client --restart='Never'  --env REDIS_PASSWORD=${REDIS_PASSWORD}  --image rapidfort/redis:latest --command -- sleep infinity
    
    # wait for client to be ready
    kubectl wait pods redis-client -n ${NAMESPACE} --for=condition=ready --timeout=10m
    
    # run benchmark test
    kubectl exec -i redis-client --namespace ${NAMESPACE} -- redis-benchmark -h ${HELM_RELEASE}-master -p 6379 -a "$REDIS_PASSWORD"
}

clean()
{
    # delete client
    kubectl -n ${NAMESPACE} delete pod redis-client

    # delete cluster
    helm delete ${HELM_RELEASE} --namespace ${NAMESPACE}
    
    # delete pvc
    kubectl -n ${NAMESPACE} delete pvc --all
}

main()
{
    test
    clean
}

main