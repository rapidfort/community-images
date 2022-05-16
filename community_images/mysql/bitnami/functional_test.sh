#!/bin/bash

set -x
set -e

HELM_RELEASE=rf-mysql
NAMESPACE=ci-test

test()
{
    helm install ${HELM_RELEASE} bitnami/mysql --set image.repository=rapidfort/mysql --namespace ${NAMESPACE}
    kubectl wait pods ${HELM_RELEASE}-0 -n ${NAMESPACE} --for=condition=ready --timeout=10m
    kubectl -n ${NAMESPACE} get pods

    MYSQL_ROOT_PASSWORD=$(kubectl get secret --namespace ${NAMESPACE} ${HELM_RELEASE} -o jsonpath="{.data.mysql-root-password}" | base64 --decode)

    kubectl -n ${NAMESPACE} exec -i ${HELM_RELEASE}-0 \
        -- /bin/bash -c \
        "mysql -h ${HELM_RELEASE}.${NAMESPACE}.svc.cluster.local -uroot -p\"$MYSQL_ROOT_PASSWORD\" -e \"CREATE SCHEMA sbtest;\""

    kubectl run -n ${NAMESPACE} sb-prepare \
        --rm -i --restart='Never' \
        --image severalnines/sysbench \
        --command -- sysbench \
        --db-driver=mysql \
        --oltp-table-size=100000 \
        --oltp-tables-count=24 \
        --threads=1 \
        --mysql-host=${HELM_RELEASE}.ci-test.svc.cluster.local \
        --mysql-port=3306 \
        --mysql-user=root \
        --mysql-password="$MYSQL_ROOT_PASSWORD" \
        --mysql-debug=on \
        /usr/share/sysbench/tests/include/oltp_legacy/parallel_prepare.lua \
        run

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
        --mysql-host=${HELM_RELEASE}.ci-test.svc.cluster.local \
        --mysql-port=3306 \
        --mysql-user=root \
        --mysql-password="$MYSQL_ROOT_PASSWORD" \
        /usr/share/sysbench/tests/include/oltp_legacy/oltp.lua \
        run
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