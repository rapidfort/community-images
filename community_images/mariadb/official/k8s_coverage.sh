#!/bin/bash

set -x
set -e

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/tests/sysbench_tests.sh

JSON_PARAMS="$1"

NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")
RELEASE_NAME=$(jq -r '.release_name' < "$JSON_PARAMS")

# get mariadb password
MARIADB_ROOT_PASSWORD=$(kubectl get secret --namespace "${NAMESPACE}" "${RELEASE_NAME}" -o jsonpath="{.data.mariadb-root-password}" | base64 --decode)

# copy test.sql into container
kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/../../common/tests/test.my_sql "${RELEASE_NAME}"-0:/tmp/test.my_sql



# run script
kubectl -n "${NAMESPACE}" exec -i "${RELEASE_NAME}"-0 -- /bin/bash -c "mysql -h localhost -uroot -p\"$MARIADB_ROOT_PASSWORD\" mysql < /tmp/test.my_sql"

# copy mysql_coverage.sh into container
kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/../../common/tests/mysql_coverage.sh "${RELEASE_NAME}"-0:/tmp/mysql_coverage.sh

# run mysql_coverage on cluster
kubectl -n "${NAMESPACE}" exec -i "${RELEASE_NAME}"-0 -- /bin/bash -c "/tmp/mysql_coverage.sh"

# create sbtest schema
kubectl -n "${NAMESPACE}" exec -i "${RELEASE_NAME}"-0 \
    -- /bin/bash -c \
    "mysql -h localhost -uroot -p\"$MARIADB_ROOT_PASSWORD\" -e \"CREATE SCHEMA sbtest;\""

# prepare benchmark
kubectl run -n "${NAMESPACE}" sb-prepare \
    --rm -i --restart='Never' \
    --image severalnines/sysbench \
    --command -- sysbench \
    --db-driver=mysql \
    --oltp-table-size=100000 \
    --oltp-tables-count=24 \
    --threads=1 \
    --mysql-host="${RELEASE_NAME}" \
    --mysql-port=3306 \
    --mysql-user=root \
    --mysql-password="${MARIADB_ROOT_PASSWORD}" \
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
    --time=30 \
    --mysql-host="${RELEASE_NAME}" \
    --mysql-port=3306 \
    --mysql-user=root \
    --mysql-password="${MARIADB_ROOT_PASSWORD}" \
    /usr/share/sysbench/tests/include/oltp_legacy/oltp.lua \
    run
