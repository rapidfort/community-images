#!/bin/bash

set -x
set -e

HELM_RELEASE=rf-postgresql
NAMESPACE=ci-test

k8s_test()
{
    # install postgres
    helm install ${HELM_RELEASE} bitnami/postgresql --set image.repository=rapidfort/postgresql --namespace ${NAMESPACE}
    
    # wait for cluster
    kubectl wait pods ${HELM_RELEASE}-0 -n ${NAMESPACE} --for=condition=ready --timeout=10m
    
    # dump pods for logging
    kubectl -n ${NAMESPACE} get pods

    # get password
    POSTGRES_PASSWORD=$(kubectl get secret --namespace ${NAMESPACE} ${HELM_RELEASE} -o jsonpath="{.data.postgres-password}" | base64 --decode)
    
    # run postgres benchmark
    kubectl run ${HELM_RELEASE}-client --rm -i --restart='Never' --namespace ${NAMESPACE} --image rapidfort/postgresql --env="PGPASSWORD=$POSTGRES_PASSWORD" --command -- pgbench --host rf-postgresql -U postgres -d postgres -p 5432 -i -s 50

    # delte cluster
    helm delete ${HELM_RELEASE} --namespace ${NAMESPACE}

    # clean up PVC
    kubectl -n ${NAMESPACE} delete pvc --all
}

docker_test()
{
    # create docker container
    docker run --rm -d -e 'POSTGRES_PASSWORD=PgPwd' -p 5432:5432 --name rf-postgresql rapidfort/postgresql:latest

    # sleep for few seconds
    sleep 30

    # get docker host ip
    PG_HOST=`docker inspect rf-postgresql | jq -r '.[].NetworkSettings.Networks.bridge.IPAddress'`

    # run test on docker container
    docker run --rm -i --env="PGPASSWORD=PgPwd" --name rf-pgbench rapidfort/postgresql -- pgbench --host ${PG_HOST} -U postgres -d postgres -p 5432 -i -s 50

    # clean up docker container
    docker kill rf-postgresql

    # prune containers
    docker image prune -a -f
}

main()
{
    k8s_test
    docker_test
}

main