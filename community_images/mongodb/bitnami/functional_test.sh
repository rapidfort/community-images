#!/bin/bash

set -x
set -e

HELM_RELEASE=rf-mongodb
NAMESPACE=ci-test

test()
{
    helm install ${HELM_RELEASE} bitnami/mongodb --set image.repository=rapidfort/mongodb --namespace ${NAMESPACE}
    kubectl wait deployments ${HELM_RELEASE} -n ${NAMESPACE} --for=condition=Available=True --timeout=10m
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