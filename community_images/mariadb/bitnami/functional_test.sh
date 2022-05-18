#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
. ${SCRIPTPATH}/../../common/helpers.sh
. ${SCRIPTPATH}/../../common/tests/sysbench_tests.sh

HELM_RELEASE=rf-mariadb
NAMESPACE=$(get_namespace_string ${HELM_RELEASE})

k8s_test()
{
    # setup namespace
    setup_namespace ${NAMESPACE}

    # install mariadb
    helm install ${HELM_RELEASE} bitnami/mariadb --set image.repository=rapidfort/mariadb --namespace ${NAMESPACE}

    # wait for mariadb
    kubectl wait pods ${HELM_RELEASE}-0 -n ${NAMESPACE} --for=condition=ready --timeout=10m

    # log pods
    kubectl -n ${NAMESPACE} get pods

    # get password
    MARIADB_ROOT_PASSWORD=$(kubectl get secret --namespace ${NAMESPACE} ${HELM_RELEASE} -o jsonpath="{.data.mariadb-root-password}" | base64 --decode)

    # create sbtest schema
    kubectl -n ${NAMESPACE} exec -i ${HELM_RELEASE}-0 \
        -- /bin/bash -c \
        "mysql -h ${HELM_RELEASE}.${NAMESPACE}.svc.cluster.local -uroot -p\"$MARIADB_ROOT_PASSWORD\" -e \"CREATE SCHEMA sbtest;\""

    # prepare benchmark
    kubectl run -n ${NAMESPACE} sb-prepare \
        --rm -i --restart='Never' \
        --image severalnines/sysbench \
        --command -- sysbench \
        --db-driver=mysql \
        --oltp-table-size=100000 \
        --oltp-tables-count=24 \
        --threads=1 \
        --mysql-host=${HELM_RELEASE}.${NAMESPACE}.svc.cluster.local \
        --mysql-port=3306 \
        --mysql-user=root \
        --mysql-password="$MARIADB_ROOT_PASSWORD" \
        --mysql-debug=on \
        /usr/share/sysbench/tests/include/oltp_legacy/parallel_prepare.lua \
        run

    # execute test
    kubectl run -n ${NAMESPACE} sb-run \
        --rm -i --restart='Never' \
        --image severalnines/sysbench \
        --command -- sysbench \
        --db-driver=mysql \
        --report-interval=2 \
        --mysql-table-engine=innodb \
        --oltp-table-size=100000 \
        --oltp-tables-count=24 \
        --threads=64 \
        --time=30 \
        --mysql-host=${HELM_RELEASE}.${NAMESPACE}.svc.cluster.local \
        --mysql-port=3306 \
        --mysql-user=root \
        --mysql-password="$MARIADB_ROOT_PASSWORD" \
        /usr/share/sysbench/tests/include/oltp_legacy/oltp.lua \
        run

    # delte cluster
    helm delete ${HELM_RELEASE} --namespace ${NAMESPACE}

    # delete pvc
    kubectl -n ${NAMESPACE} delete pvc --all

    # clean up namespace
    cleanup_namespace ${NAMESPACE}
}

docker_test()
{
    MARIADB_ROOT_PASSWORD=my_root_password

    # create network
    docker network create -d bridge ${NAMESPACE}

    # create docker container
    docker run --rm -d --network=${NAMESPACE} \
        -e "MARIADB_ROOT_PASSWORD=${MARIADB_ROOT_PASSWORD}" -p 3306:3306 --name ${HELM_RELEASE} rapidfort/mariadb:latest

    # sleep for few seconds
    sleep 30

    # get docker host ip
    MARIADB_HOST=`docker inspect ${HELM_RELEASE} | jq -r ".[].NetworkSettings.Networks[\"${NAMESPACE}\"].IPAddress"`

    run_sys_bench_test $MARIADB_HOST $MARIADB_ROOT_PASSWORD ${NAMESPACE} no

    # clean up docker container
    docker kill ${HELM_RELEASE}

    # delete network
    docker network rm ${NAMESPACE}
}

docker_compose_test()
{
    # update image in docker-compose yml
    sed "s#@IMAGE#rapidfort/mariadb#g" ${SCRIPTPATH}/docker-compose.yml.base > ${SCRIPTPATH}/docker-compose.yml

    # install postgresql container
    docker-compose -f ${SCRIPTPATH}/docker-compose.yml -p ${NAMESPACE} up -d

    # sleep for 30 sec
    sleep 30

    # password
    MARIADB_ROOT_PASSWORD=my_root_password

    # logs for tracking
    docker-compose -f ${SCRIPTPATH}/docker-compose.yml -p ${NAMESPACE} logs

    # run pg benchmark container
    run_sys_bench_test mariadb-master $MARIADB_ROOT_PASSWORD ${NAMESPACE}_default no

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