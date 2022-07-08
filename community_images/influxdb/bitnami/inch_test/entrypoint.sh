#!/bin/bash

set -x
set -e

if [[ -z "$INFLUXDB_HOST" ]]; then
    echo "Must provide INFLUXDB_HOST in environment" 1>&2
    exit 1
fi

if [[ -z "$INFLUXDB_PASSWORD" ]]; then
    echo "Must provide INFLUXDB_PASSWORD in environment" 1>&2
    exit 1
fi

CONCURRENCY="${CONCURRENCY:-8}"
BATCH="${BATCH:-10000}"
TAG_CARDINALITY="${TAG_CARDINALITY:-2,5000,1}"
POINTS_PER_SERIES="${POINTS_PER_SERIES:-100000}"
CONSISTENCY="${CONSISTENCY:-any}"

inch -v -c 8 -b 10000 -t 2,5000,1 -p 100000 -consistency any
