#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker coverage = $JSON"

CONTAINER_NAME=$(jq -r '.container_details."mysql-official".name' < "$JSON_PARAMS")
NETWORK_NAME=$(jq -r '.network_name' < "$JSON_PARAMS")
MYSQL_HOST=$(jq -r '.container_details."mysql-official".ip_address' < "$JSON_PARAMS")

SCRIPTPATH=$(jq -r '.image_script_dir' < "$JSON_PARAMS")


# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/tests/sysbench_tests.sh

# get mysql password
MYSQL_ROOT_PASSWORD=my_root_password

# copy test.sql into container
docker cp "${SCRIPTPATH}"/../../common/tests/test.my_sql "${CONTAINER_NAME}":/tmp/test.my_sql

# run script
docker exec -i "${CONTAINER_NAME}" \
    /bin/bash -c "mysql -h localhost -uroot -p\"$MYSQL_ROOT_PASSWORD\" mysql < /tmp/test.my_sql"

# copy mysql_coverage.sh into container
docker cp "${SCRIPTPATH}"mysql_coverage.sh "${CONTAINER_NAME}":/tmp/mysql_coverage.sh

# run mysql_coverage on cluster
docker exec -i "${CONTAINER_NAME}" /bin/bash -c "/tmp/mysql_coverage.sh"

# create sbtest schema
docker exec -i "${CONTAINER_NAME}" \
    /bin/bash -c \
    "mysql -h localhost -uroot -p\"$MYSQL_ROOT_PASSWORD\" -e \"CREATE SCHEMA sbtest;\""

# prepare benchmark
docker run --network="${NETWORK_NAME}" \
    --name sb-prepare --rm -i \
    severalnines/sysbench \
    sysbench \
    --db-driver=mysql \
    --oltp-table-size=100000 \
    --oltp-tables-count=24 \
    --threads=1 \
    --mysql-host="${MYSQL_HOST}" \
    --mysql-port=3306 \
    --mysql-user=root \
    --mysql-password="${MYSQL_ROOT_PASSWORD}" \
    --mysql-debug=on \
    /usr/share/sysbench/tests/include/oltp_legacy/parallel_prepare.lua \
    run

# execute test
docker run --network="${NETWORK_NAME}" \
    --name sb-run --rm -i \
    severalnines/sysbench \
    sysbench \
    --db-driver=mysql \
    --report-interval=2 \
    --mysql-table-engine=innodb \
    --oltp-table-size=100000 \
    --oltp-tables-count=24 \
    --threads=4 \
    --time=45 \
    --mysql-host="${MYSQL_HOST}" \
    --mysql-port=3306 \
    --mysql-user=root \
    --mysql-password="${MYSQL_ROOT_PASSWORD}" \
    /usr/share/sysbench/tests/include/oltp_legacy/oltp.lua \
    run
