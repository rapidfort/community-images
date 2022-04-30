#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
. ${SCRIPTPATH}/../../common/helpers.sh


BASE_TAG=2.8.1.1-b
INPUT_REGISTRY=docker.io
INPUT_ACCOUNT=yugabytedb
REPOSITORY=yugabyte


test()
{
    local IMAGE_REPOSITORY=$1
    local TAG=$2

    echo "Testing yugabytedb"
    docker run --rm -d --name yugabyte-${TAG} -p7000:7000 -p9000:9000 -p5433:5433 -p9042:9042 --cap-add=SYS_PTRACE ${IMAGE_REPOSITORY}:${TAG} bin/yugabyted start --base_dir=/home/yugabyte/yb_data --daemon=false

    # sleep for 1 min
    echo "waiting for 1 min for setup"
    sleep 1m

    #curl into UI
    curl http://localhost:7000
    curl http://localhost:9000

    # copy sql script
    docker cp ${SCRIPTPATH}/../../common/tests/test.psql yugabyte-${TAG}:/tmp/test.psql

    #run script
    docker exec -i yugabyte-${TAG} ysqlsh -h localhost -p 5433 -f /tmp/test.psql

    # kill docker container
    docker kill yugabyte-${TAG}
}

build_images ${INPUT_REGISTRY} ${INPUT_ACCOUNT} ${REPOSITORY} ${BASE_TAG} test
