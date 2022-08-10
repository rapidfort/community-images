#!/bin/bash

set -x
set -e

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/tests/sysbench_tests.sh

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker coverage = $JSON"

NETWORK_NAME=$(jq -r '.network_name' < "$JSON_PARAMS")

# get docker host ip
MYSQL_HOST=$(jq -r '.container_details.mysql.ip_address' < "$JSON_PARAMS")

MYSQL_ROOT_PASSWORD=my_root_password

# run sys bench test
# run_sys_bench_test "$MYSQL_HOST" "$MYSQL_ROOT_PASSWORD" "${NETWORK_NAME}" yes
