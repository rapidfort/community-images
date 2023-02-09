#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/scripts/bash_helper.sh

function test_telegraf() {
    local ORG=$1
    local TOKEN=$2
    wget https://dl.influxdata.com/influxdb/releases/influxdb2-client-2.6.1-linux-amd64.tar.gz
    tar xvzf influxdb2-client-2.6.1-linux-amd64.tar.gz
    sudo cp influxdb2-client-2.6.1-linux-amd64/influx /usr/local/bin/
    # bring up a client influxdb instance
    influx query 'from(bucket:"example_bucket") |> range(start:-1m)' --org "${ORG}" -t "${TOKEN}"
}

function setup_telegraf() {
    local NAMESPACE=$1
    # local CONTAINER_NAME=$2
    # create a sample telegraf configuration file
    telegraf --sample-config --input-filter cpu:mem --output-filter influxdb_v2\
     --aggregator-filter : --processor-filter : > telegraf.conf
    # start the telegraf server
    # telegraf --config telegraf.conf
}

function setup_influxdb() {
    local NAMESPACE=$1
    # start the influxdb
    INFLUXDB_POD_NAME="influxdb_telegraf"
    docker run --name influxdb_telegraf --net "${NAMESPACE}" -p 8086:8086 \
        -p 8088:8088 -d rapidfort/influxdb

    # create the bucket and and example org
    chmod +x "${SCRIPTPATH}"/influx_bucket_org_create.sh
    docker cp "${SCRIPTPATH}"/influx_bucket_org_create.sh "${INFLUXDB_POD_NAME}":/tmp/influx_bucket_org_create.sh

    with_backoff docker exec -t "${INFLUXDB_POD_NAME}" bash /tmp/influx_bucket_org_create.sh
}