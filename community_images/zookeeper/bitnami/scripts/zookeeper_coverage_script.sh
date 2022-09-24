#!/bin/bash

set -e
set -x

# run zookeeper specific commands for coverage
zkCli.sh <<EOF
create /FirstZnode "simple data node"
get /FirstZnode
ls /
delete /FirstZnode
create -s /SeqZnode second-data
get /SeqZnode
deleteall /SeqZnode
create -e /EphZnode third-data
get /EphZnode
getEphemerals /
delete /EphZnode
create /FirstZnode "simple data node"
create /FirstZnode/Child1 "firstchildren"
create /FirstZnode/Child2 "secondchildren"
ls /FirstZnode
getAllChildrenNumber /FirstZnode
stat /FirstZnode
deleteall /FirstZnode
create /quota_test "quota testing"
setquota -n 2 /quota_test
create /quota_test/child_1
create /quota_test/child_2
create /quota_test/child_3
listquota /quota_test
EOF