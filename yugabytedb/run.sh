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
    docker run -d --name yugabyte-$1 -p7000:7000 -p9000:9000 -p5433:5433 -p9042:9042 --cap-add=SYS_PTRACE ${OREPO}:${TAG} bin/yugabyted start --base_dir=/home/yugabyte/yb_data --daemon=false

    # exec into docker
    docker exec -it yugabyte-$1 bash

    #curl into UI
    curl http://localhost:7000
    curl http://localhost:9000

    #run script
    docker exec -it yugabyte-$1 ysqlsh

    # # Install postgresql
    # helm install ${HELM_RELEASE}  ${IREPO} --namespace ${NAMESPACE} --set image.tag=${TAG} -f overrides.yml

    # # sleep for 1 min
    # echo "waiting for 1 min for setup"
    # sleep 1m

    # # get postgresql passwordk
    # POSTGRES_PASSWORD=$(kubectl get secret --namespace ${NAMESPACE} ${HELM_RELEASE} -o jsonpath="{.data.postgres-password}" | base64 --decode)

    # # copy test.sql into container
    # kubectl -n ${NAMESPACE} cp test.sql ${HELM_RELEASE}-0:/tmp/test.sql

    # # exec into container
    # kubectl -n ${NAMESPACE} exec -it ${HELM_RELEASE}-0 -- /bin/bash -c "PGPASSWORD=${POSTGRES_PASSWORD} psql --host ${HELM_RELEASE} -U postgres -d postgres -p 5432 -f /tmp/test.sql"

    # # sleep for 30 sec
    # echo "waiting for 30 sec"
    # sleep 30

    # # bring down helm install
    # helm delete ${HELM_RELEASE} --namespace ${NAMESPACE}

    # # delete the PVC associated
    # kubectl -n ${NAMESPACE} delete pvc data-${HELM_RELEASE}-0

    # # sleep for 30 sec
    # echo "waiting for 30 sec"
    # sleep 30
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
