#!/bin/bash

set -x
set -e


# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/tests/sysbench_tests.sh

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

NETWORK_NAME=$(jq -r '.network_name' < "$JSON_PARAMS")

# run pg benchmark container
run_sys_bench_test mariadb-master "$MARIADB_ROOT_PASSWORD" "${NETWORK_NAME}" no
