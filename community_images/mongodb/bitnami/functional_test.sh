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

    # create MongoDB client
    # kubectl run -n ${NAMESPACE} mongodb-perf \
    #     --restart='Never' \
    #     --env="MONGODB_ROOT_PASSWORD=${MONGODB_ROOT_PASSWORD}" \
    #     --image rapidfort/mongodb-perfomance-test:latest \
    #     --command -- "java -jar /mongodb-performance-test/latest-version/mongodb-performance-test.jar  -m insert -o 1000000 -t 100 -db test -c perf -port 28888 -h \"mongodb-release\" -u root -p ${MONGODB_ROOT_PASSWORD} -adb admin"

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