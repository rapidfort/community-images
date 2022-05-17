#!/bin/bash

set -x
set -e

HELM_RELEASE=rf-mongodb
NAMESPACE=ci-test

k8s_perf_runner()
{
    OPERATION=$1

    kubectl run -n ${NAMESPACE} mongodb-perf \
        --rm -i --restart='Never' \
        --env="MONGODB_OPERATION=${OPERATION}" \
        --env="MONGODB_HOST=${HELM_RELEASE}" \
        --env="MONGODB_ROOT_PASSWORD=${MONGODB_ROOT_PASSWORD}" \
        --image rapidfort/mongodb-perfomance-test:latest
}

k8s_test()
{
    # install mongodb
    helm install ${HELM_RELEASE} bitnami/mongodb --set image.repository=rapidfort/mongodb --namespace ${NAMESPACE}

    # wait for mongodb
    kubectl wait deployments ${HELM_RELEASE} -n ${NAMESPACE} --for=condition=Available=True --timeout=10m

    # log pods
    kubectl -n ${NAMESPACE} get pods

    # get mongodb password
    MONGODB_ROOT_PASSWORD=$(kubectl get secret --namespace ${NAMESPACE} ${HELM_RELEASE} -o jsonpath="{.data.mongodb-root-password}" | base64 --decode)

    # run MongoDB tests
    k8s_perf_runner INSERT
    k8s_perf_runner UPDATE_MANY
    k8s_perf_runner ITERATE_MANY
    k8s_perf_runner DELETE_MANY

    # delte cluster
    helm delete ${HELM_RELEASE} --namespace ${NAMESPACE}

    # delete pvc
    kubectl -n ${NAMESPACE} delete pvc --all
}

main()
{
    k8s_test
}

main