#!/bin/bash

set -x
set -e

if [[ -z "$MONGODB_HOST" ]]; then
    echo "Must provide MONGODB_HOST in environment" 1>&2
    exit 1
fi

if [[ -z "$MONGODB_ROOT_PASSWORD" ]]; then
    echo "Must provide MONGODB_ROOT_PASSWORD in environment" 1>&2
    exit 1
fi

MONGODB_OPERATION="${MONGODB_OPERATION:-INSERT}"
MONGODB_PORT="${MONGODB_PORT:-27017}"
MONGODB_USER="${MONGODB_USER:-root}"
MONGODB_AUTHDB="${MONGODB_AUTHDB:-admin}"
DURATION="${DURATION:-30}"

java -jar /mongodb-performance-test/latest-version/mongodb-performance-test.jar \
    -m "${MONGODB_OPERATION}" -o 1000000 -t 100 -db test -c perf -port "${MONGODB_PORT}" \
    -h "${MONGODB_HOST}" -u "${MONGODB_USER}" -p "${MONGODB_ROOT_PASSWORD}" -adb "${MONGODB_AUTHDB}" -d "${DURATION}"
