#!/bin/bash

set -x
set -e

HELM_RELEASE=rf-mysql
NAMESPACE=ci-test

test()
{
    helm install ${HELM_RELEASE} bitnami/mysql --set image.repository=rapidfort/mysql --namespace ${NAMESPACE}
    kubectl wait pods ${HELM_RELEASE}-0 -n ${NAMESPACE} --for=condition=ready --timeout=10m
    kubectl -n ${NAMESPACE} get pods
}

clean()
{
    helm delete ${HELM_RELEASE} --namespace ${NAMESPACE}
    kubectl -n ${NAMESPACE} delete pvc --all
}

main()
{
    test
    clean
}

main