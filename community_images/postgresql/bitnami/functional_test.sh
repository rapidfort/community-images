#!/bin/bash

set -x
set -e

HELM_RELEASE=rf-postgresql
NAMESPACE=ci-test

test()
{
    helm install ${HELM_RELEASE} bitnami/postgresql --set image.repository=rapidfort/postgresql --namespace ${NAMESPACE}
    kubectl wait pods ${HELM_RELEASE}-0 -n ${NAMESPACE} --for=condition=ready --timeout=10m
    kubectl -n ${NAMESPACE} get pods

    kubectl run ${HELM_RELEASE}-client --rm -i --restart='Never' --namespace ${NAMESPACE} --image rapidfort/postgresql --env="PGPASSWORD=$POSTGRES_PASSWORD" --command -- pgbench --host rf-postgresql -U postgres -d postgres -p 5432 -i -s 50
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