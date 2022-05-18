#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
. ${SCRIPTPATH}/../../common/helpers.sh

HELM_RELEASE=rf-postgresql
NAMESPACE=$(get_namespace_string ${HELM_RELEASE})

k8s_test()
{
    # setup namespace
    setup_namespace ${NAMESPACE}

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

    # clean up namespace
    cleanup_namespace ${NAMESPACE}
}

docker_test()
{
    # create network
    docker network create -d bridge ${NAMESPACE}

    # create docker container
    docker run --rm -d --network=${NAMESPACE} \
        -e 'POSTGRES_PASSWORD=PgPwd' \
        --name rf-postgresql rapidfort/postgresql:latest

    # sleep for few seconds
    sleep 30

    # get docker host ip
    PG_HOST=`docker inspect ${HELM_RELEASE} | jq -r ".[].NetworkSettings.Networks[\"${NAMESPACE}\"].IPAddress"`

    # run test on docker container
    docker run --rm --network=${NAMESPACE} \
        -i --env="PGPASSWORD=PgPwd" --name rf-pgbench rapidfort/postgresql \
        -- pgbench --host ${PG_HOST} -U postgres -d postgres -p 5432 -i -s 50

    # clean up docker container
    docker kill rf-postgresql

    # delete network
    docker network rm ${NAMESPACE}
}

docker_compose_test()
{
    # update image in docker-compose yml
    sed "s#@IMAGE#rapidfort/postgresql#g" ${SCRIPTPATH}/docker-compose.yml.base > ${SCRIPTPATH}/docker-compose.yml

    # install postgresql container
    docker-compose -f ${SCRIPTPATH}/docker-compose.yml -p ${NAMESPACE} up -d

    # sleep for 30 sec
    sleep 30

    # password
    POSTGRES_PASSWORD=my_password

    # logs for tracking
    docker-compose -f ${SCRIPTPATH}/docker-compose.yml -p ${NAMESPACE} logs

    # run pg benchmark container
    docker run --rm -i --network="${NAMESPACE}_default" \
        --env="PGPASSWORD=${POSTGRES_PASSWORD}" --name rf-pgbench rapidfort/postgresql \
        -- pgbench --host postgresql-master -U postgres -d postgres -p 5432 -i -s 50

    # kill docker-compose setup container
    docker-compose -f ${SCRIPTPATH}/docker-compose.yml -p ${NAMESPACE} down

    # clean up docker file
    rm -rf ${SCRIPTPATH}/docker-compose.yml
}

main()
{
    k8s_test
    docker_test
    docker_compose_test
}

main