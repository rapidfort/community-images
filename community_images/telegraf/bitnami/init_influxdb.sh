#!/bin/sh

set -e
influx org create --name example_org -t admintoken123 --host 'http://influxdb:8086'
influx bucket create -n example_bucket -t admintoken123 --org example_org -r 7d --host 'http://influxdb:8086'