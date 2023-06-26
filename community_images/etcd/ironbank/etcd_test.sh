#!/bin/bash

set -x
set -e

if [[ $# -ne 1 ]]; then
    echo "Usage:$0 <ROOT_PASSWORD>"
    exit 1
fi

ROOT_PASSWORD=etcdrootpwd

function etcd_cmd()
{
    etcdctl --user=root:$ROOT_PASSWORD "$@"
}

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
