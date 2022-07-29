#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/helpers.sh

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/tests/sysbench_tests.sh

HELM_RELEASE=rf-mysql
NAMESPACE=$(get_namespace_string "${HELM_RELEASE}")
IMAGE_REPOSITORY=rapidfort/mysql

k8s_test()
{
    # setup namespace
    setup_namespace "${NAMESPACE}"

    # install mysql
    with_backoff helm install "${HELM_RELEASE}" bitnami/mysql --set image.repository="${IMAGE_REPOSITORY}" --namespace "${NAMESPACE}"
    report_pulls "${IMAGE_REPOSITORY}"

    # wait for mysql
    kubectl wait pods "${HELM_RELEASE}"-0 -n "${NAMESPACE}" --for=condition=ready --timeout=10m

    # log pods
    kubectl -n "${NAMESPACE}" get pods

    # get password
    MYSQL_ROOT_PASSWORD=$(kubectl get secret --namespace "${NAMESPACE}" "${HELM_RELEASE}" -o jsonpath="{.data.mysql-root-password}" | base64 --decode)

    # create sbtest schema
    kubectl -n "${NAMESPACE}" exec -i "${HELM_RELEASE}"-0 \
        -- /bin/bash -c \
        "mysql -h localhost -uroot -p\"$MYSQL_ROOT_PASSWORD\" -e \"CREATE SCHEMA sbtest;\""

    # prepare benchmark
    kubectl run -n "${NAMESPACE}" sb-prepare \
        --rm -i --restart='Never' \
        --image severalnines/sysbench \
        --command -- sysbench \
        --db-driver=mysql \
        --oltp-table-size=100000 \
        --oltp-tables-count=24 \
        --threads=1 \
        --mysql-host="${HELM_RELEASE}" \
        --mysql-port=3306 \
        --mysql-user=root \
        --mysql-password="${MYSQL_ROOT_PASSWORD}" \
        --mysql-debug=on \
        /usr/share/sysbench/tests/include/oltp_legacy/parallel_prepare.lua \
        run

    # execute test
    kubectl run -n "${NAMESPACE}" sb-run \
        --rm -i --restart='Never' \
        --image severalnines/sysbench \
        --command -- sysbench \
        --db-driver=mysql \
        --report-interval=2 \
        --mysql-table-engine=innodb \
        --oltp-table-size=100000 \
        --oltp-tables-count=24 \
        --threads=4 \
        --time=45 \
        --mysql-host="${HELM_RELEASE}" \
        --mysql-port=3306 \
        --mysql-user=root \
        --mysql-password="${MYSQL_ROOT_PASSWORD}" \
        /usr/share/sysbench/tests/include/oltp_legacy/oltp.lua \
        run

    # delte cluster
    helm delete "${HELM_RELEASE}" --namespace "${NAMESPACE}"

    # delete pvc
    kubectl -n "${NAMESPACE}" delete pvc --all

    # clean up namespace
    cleanup_namespace "${NAMESPACE}"
}

docker_test()
{
    MYSQL_ROOT_PASSWORD=my_root_password

    # create network
    docker network create -d bridge "${NAMESPACE}"

    # create docker container
    docker run --rm -d --network="${NAMESPACE}" \
        -e "MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}" \
        --name "${NAMESPACE}" "${IMAGE_REPOSITORY}":latest
    report_pulls "${IMAGE_REPOSITORY}"

    # sleep for 60 seconds
    sleep 60

    # get docker host ip
    MYSQL_HOST=$(docker inspect "${NAMESPACE}" | jq -r ".[].NetworkSettings.Networks[\"${NAMESPACE}\"].IPAddress")

    run_sys_bench_test "$MYSQL_HOST" "$MYSQL_ROOT_PASSWORD" "${NAMESPACE}" yes

    # clean up docker container
    docker kill "${NAMESPACE}"

    # delete network
    docker network rm "${NAMESPACE}"
}

docker_compose_test()
{
    # update image in docker-compose yml
    sed "s#@IMAGE#${IMAGE_REPOSITORY}#g" "${SCRIPTPATH}"/docker-compose.yml.base > "${SCRIPTPATH}"/docker-compose.yml

    # install postgresql container
    docker-compose -f "${SCRIPTPATH}"/docker-compose.yml -p "${NAMESPACE}" up -d
    report_pulls "${IMAGE_REPOSITORY}" 2

    # sleep for 60 sec
    sleep 60

    # password
    MYSQL_ROOT_PASSWORD=my_root_password

    # logs for tracking
    docker-compose -f "${SCRIPTPATH}"/docker-compose.yml -p "${NAMESPACE}" logs

    # run pg benchmark container
    run_sys_bench_test mysql-master "$MYSQL_ROOT_PASSWORD" "${NAMESPACE}"-default yes

    # kill docker-compose setup container
    docker-compose -f "${SCRIPTPATH}"/docker-compose.yml -p "${NAMESPACE}" down

    # clean up docker file
    rm -rf "${SCRIPTPATH}"/docker-compose.yml
}

main()
{
    k8s_test
    docker_test
    docker_compose_test
}

main