#!/bin/bash

set -x

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <tag>"
    exit 1
fi

TAG=$1 #2.8.1.1-b5
echo "Running image generation for $0 $1 $2"

IREGISTRY=docker.io
IREPO=yugabytedb/yugabyte
OREPO=rapidfort/yugabyte-rfstub
PUB_REPO=rapidfort/yugabyte
HELM_RELEASE=yugabyte-release


create_stub()
{
    # Pull docker image
    docker pull ${IREGISTRY}/${IREPO}:${TAG}
    # Create stub for docker image
    rfstub ${IREGISTRY}/${IREPO}:${TAG}

    # Change tag to point to rapidfort docker account
    docker tag ${IREGISTRY}/${IREPO}:${TAG}-rfstub ${OREPO}:${TAG}

    # Push stub to our dockerhub account
    docker push ${OREPO}:${TAG}
}


test()
{
    echo "Testing yugabytedb"
    docker run --rm -d --name yugabyte-${TAG} -p7000:7000 -p9000:9000 -p5433:5433 -p9042:9042 --cap-add=SYS_PTRACE ${OREPO}:${TAG} bin/yugabyted start --base_dir=/home/yugabyte/yb_data --daemon=false

    #curl into UI
    curl http://localhost:7000
    curl http://localhost:9000

    # copy sql script
    docker cp test.sql yugabyte-${TAG}:/tmp/test.sql

    #run script
    docker exec -it yugabyte-${TAG} ysqlsh -h localhost -p 5433 -f /tmp/test.sql

    # kill docker container
    docker kill yugabyte-${TAG}
}

harden_image()
{
    # Create stub for docker image
    rfharden ${IREGISTRY}/${IREPO}:${TAG}-rfstub

    # Change tag to point to rapidfort docker account
    docker tag ${IREGISTRY}/${IREPO}:${TAG}-rfhardened ${PUB_REPO}:${TAG}

    # Push stub to our dockerhub account
    docker push ${PUB_REPO}:${TAG}

    echo "Hardened images pushed to ${PUB_REPO}:${TAG}" 
}


main()
{
    create_stub
    test
    harden_image
}

main
