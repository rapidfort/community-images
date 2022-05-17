#!/bin/bash

set -x
set -e

HELM_RELEASE=rf-mysql
NAMESPACE=ci-test
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

k8s_test()
{
    # install mysql
    helm install ${HELM_RELEASE} bitnami/mysql --set image.repository=rapidfort/mysql --namespace ${NAMESPACE}

    # wait for mysql
    kubectl wait pods ${HELM_RELEASE}-0 -n ${NAMESPACE} --for=condition=ready --timeout=10m

    # log pods
    kubectl -n ${NAMESPACE} get pods

    # get password
    MYSQL_ROOT_PASSWORD=$(kubectl get secret --namespace ${NAMESPACE} ${HELM_RELEASE} -o jsonpath="{.data.mysql-root-password}" | base64 --decode)

    # create sbtest schema
    kubectl -n ${NAMESPACE} exec -i ${HELM_RELEASE}-0 \
        -- /bin/bash -c \
        "mysql -h ${HELM_RELEASE}.${NAMESPACE}.svc.cluster.local -uroot -p\"$MYSQL_ROOT_PASSWORD\" -e \"CREATE SCHEMA sbtest;\""

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
        --mysql-password="$MYSQL_ROOT_PASSWORD" \
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
        --mysql-password="$MYSQL_ROOT_PASSWORD" \
        /usr/share/sysbench/tests/include/oltp_legacy/oltp.lua \
        run

    # delte cluster
    helm delete ${HELM_RELEASE} --namespace ${NAMESPACE}

    # delete pvc
    kubectl -n ${NAMESPACE} delete pvc --all
}

docker_test()
{
    MYSQL_ROOT_PASSWORD=my_root_password
    # create docker container
    docker run --rm -d -e "MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}" -p 3306:3306 --name ${HELM_RELEASE} rapidfort/mysql:latest

    # sleep for few seconds
    sleep 30

    # get docker host ip
    MYSQL_HOST=`docker inspect ${HELM_RELEASE} | jq -r '.[].NetworkSettings.Networks.bridge.IPAddress'`

    # create role
    docker run --rm -i --name mysql-client rapidfort/mysql:latest \
        -- mysql -h ${MYSQL_HOST} -uroot -p"$MYSQL_ROOT_PASSWORD" -e "CREATE SCHEMA sbtest;"

    # run sys bench prepare
    docker run \
        --rm=true \
        --name=sb-prepare \
        severalnines/sysbench \
        sysbench \
        --db-driver=mysql \
        --oltp-table-size=100000 \
        --oltp-tables-count=24 \
        --threads=1 \
        --mysql-host=${MYSQL_HOST} \
        --mysql-port=3306 \
        --mysql-user=sbtest \
        --mysql-password=${MYSQL_ROOT_PASSWORD} \
        /usr/share/sysbench/tests/include/oltp_legacy/parallel_prepare.lua \
        run

    # run sys bench test
    docker run \
        --name=sb-run \
        severalnines/sysbench \
        sysbench \
        --db-driver=mysql \
        --report-interval=2 \
        --mysql-table-engine=innodb \
        --oltp-table-size=100000 \
        --oltp-tables-count=24 \
        --threads=64 \
        --time=99999 \
        --mysql-host=${MYSQL_HOST} \
        --mysql-port=3306 \
        --mysql-user=sbtest \
        --mysql-password=${MYSQL_ROOT_PASSWORD} \
        /usr/share/sysbench/tests/include/oltp_legacy/oltp.lua \
        run

    # clean up docker container
    docker kill ${HELM_RELEASE}

    # prune containers
    docker image prune -a -f
}

docker_compose_test()
{

}

main()
{
    k8s_test
    docker_test
    docker_compose_test
}

main