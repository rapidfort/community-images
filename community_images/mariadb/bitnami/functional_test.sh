#!/bin/bash

set -x
set -e

HELM_RELEASE=rf-mariadb-cluster
NAMESPACE=ci-test

test()
{
    helm install ${HELM_RELEASE} bitnami/mariadb --set image.repository=rapidfort/mariadb --namespace ${NAMESPACE}
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