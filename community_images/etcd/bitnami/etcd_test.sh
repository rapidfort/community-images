#!/bin/bash


ROOT_PASSWORD=$1

function etc_cmd()
{
    etcdctl --user root:"$ROOT_PASSWORD" "$@"
} 

etc_cmd version

etc_cmd put foo bar

etc_cmd put foo1 bar1 --lease=1234abcd

etc_cmd get foo

etc_cmd get foo --hex

etc_cmd get foo --print-value-only

etc_cmd get --prefix foo

etc_cmd del foo

etc_cmd watch foo &

etc_cmd set foo test1

etc_cmd alarm list
