#!/bin/bash

set -x
set -e

java -jar /mongodb-performance-test/latest-version/mongodb-performance-test.jar \
    -m "${MONGODB_OPERATION}" -o 1000000 -t 100 -db test -c perf -port "${MONGODB_PORT}" \
    -h "${MONGODB_HOST}" -u root -p "${MONGODB_ROOT_PASSWORD}" -adb "${MONGODB_AUTHDB}"
