#!/bin/bash

set -x
set -e

HELM_RELEASE=rf-redis-cluster
NAMESPACE=ci-test

test()
{
    # install redis
    helm install ${HELM_RELEASE} bitnami/redis-cluster --set image.repository=rapidfort/redis-cluster --namespace ${NAMESPACE}

    # wait for redis
    kubectl wait pods ${HELM_RELEASE}-0 -n ${NAMESPACE} --for=condition=ready --timeout=10m

    # for logs dump pods
    kubectl -n ${NAMESPACE} get pods

    # get password
    REDIS_PASSWORD=$(kubectl get secret --namespace ${NAMESPACE} ${HELM_RELEASE} -o jsonpath="{.data.redis-password}" | base64 --decode)

    # run redis-client
    kubectl run ${HELM_RELEASE}-client --rm -i --restart='Never' --namespace ${NAMESPACE} --image rapidfort/redis-cluster --command -- redis-benchmark -h ${HELM_RELEASE} -a "$REDIS_PASSWORD" --cluster
}

clean()
{
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