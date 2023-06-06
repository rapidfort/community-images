#!/bin/bash

set -x
set -e

function etcd_cmd()
{
    etcdctl --user root:password123 "$@"
}

etcdctl user add root:password123

etcdctl user get root | grep Roles | grep --silent root

etcdctl auth enable

etcd_cmd version

etcd_cmd put foo bar

etcd_cmd lease grant 10

etcd_cmd get foo

etcd_cmd get foo --hex

etcd_cmd get foo --print-value-only

etcd_cmd get --prefix foo

etcd_cmd del foo

etcd_cmd watch foo &

etcd_cmd alarm list

etcd_cmd check perf

etcd_cmd check datascale

etcd_cmd endpoint health

etcd_cmd endpoint status

etcd_cmd member list
