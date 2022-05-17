#!/bin/bash

set -x
set -e

HELM_RELEASE=rf-postgresql
NAMESPACE=ci-test
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

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

docker_compose_test()
{
    # update image in docker-compose yml
    sed "s#@IMAGE#rapidfort/redis#g" ${SCRIPTPATH}/docker-compose.yml.base > ${SCRIPTPATH}/docker-compose.yml

    # install redis container
    docker-compose -f ${SCRIPTPATH}/docker-compose.yml up -d

    # sleep for 30 sec
    sleep 30

    # password
    POSTGRES_PASSWORD=my_password

    # logs for tracking
    docker-compose -f ${SCRIPTPATH}/docker-compose.yml logs

    # run pg benchmark container
    docker run --rm -i --env="PGPASSWORD=${POSTGRES_PASSWORD}" --name rf-pgbench rapidfort/postgresql -- pgbench --host postgresql-master -U postgres -d postgres -p 5432 -i -s 50

    # kill docker-compose setup container
    docker-compose -f ${SCRIPTPATH}/docker-compose.yml down

    # clean up docker file
    rm -rf ${SCRIPTPATH}/docker-compose.yml

    # prune containers
    docker image prune -a -f
}

main()
{
    k8s_test
    docker_test
    docker_compose_test
}

main