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

    # get mongodb password
    MONGODB_ROOT_PASSWORD=$(kubectl get secret --namespace ${NAMESPACE} ${HELM_RELEASE} -o jsonpath="{.data.mongodb-root-password}" | base64 --decode)

    # run MongoDB client INSERT
    kubectl run -n ${NAMESPACE} mongodb-perf \
        --rm -i --restart='Never' \
        --env="MONGODB_OPERATION=INSERT" \
        --env="MONGODB_HOST=${HELM_RELEASE}" \
        --env="MONGODB_ROOT_PASSWORD=${MONGODB_ROOT_PASSWORD}" \
        --image rapidfort/mongodb-perfomance-test:latest

    # run MongoDB client UPDATE_MANY
    kubectl run -n ${NAMESPACE} mongodb-perf \
        --rm -i --restart='Never' \
        --env="MONGODB_OPERATION=UPDATE_MANY" \
        --env="MONGODB_HOST=${HELM_RELEASE}" \
        --env="MONGODB_ROOT_PASSWORD=${MONGODB_ROOT_PASSWORD}" \
        --image rapidfort/mongodb-perfomance-test:latest

    # run MongoDB client ITERATE_MANY
    kubectl run -n ${NAMESPACE} mongodb-perf \
        --rm -i --restart='Never' \
        --env="MONGODB_OPERATION=ITERATE_MANY" \
        --env="MONGODB_HOST=${HELM_RELEASE}" \
        --env="MONGODB_ROOT_PASSWORD=${MONGODB_ROOT_PASSWORD}" \
        --image rapidfort/mongodb-perfomance-test:latest

    # run MongoDB client DELETE_MANY
    kubectl run -n ${NAMESPACE} mongodb-perf \
        --rm -i --restart='Never' \
        --env="MONGODB_OPERATION=DELETE_MANY" \
        --env="MONGODB_HOST=${HELM_RELEASE}" \
        --env="MONGODB_ROOT_PASSWORD=${MONGODB_ROOT_PASSWORD}" \
        --image rapidfort/mongodb-perfomance-test:latest
}

clean()
{
    helm delete ${HELM_RELEASE} --namespace ${NAMESPACE}
    kubectl -n ${NAMESPACE} delete pvc --all
}

main()
{
    test
    # clean
}

main