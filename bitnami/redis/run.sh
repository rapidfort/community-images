if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <k8s-namespace> <tag>"
fi

NAMESPACE=$1 #ci-dev
TAG=$2 #6.2.6-debian-10-r103
echo "Running image generation for $0 $1 $2"

IREGISTRY=docker.io
IREPO=bitnami/redis
OREPO=rapidfort/redis-rfstub
PUB_REPO=rapidfort/redis
HELM_RELEASE=stub-run-release

setup()
{
    # Pull docker image
    docker pull ${IREGISTRY}/${IREPO}:${TAG}
    # Create stub for docker image
    rfstub ${IREGISTRY}/${IREPO}:${TAG}

    # Change tag to point to rapidfort docker account
    docker tag ${IREGISTRY}/${IREPO}:${TAG}-rfstub ${OREPO}:${TAG}

    # Push stub to our dockerhub account
    docker push ${OREPO}:${TAG}

    # Install redis
    helm install ${HELM_RELEASE}  ${IREPO} --namespace ${NAMESPACE} --set image.tag=${TAG} -f overrides.yml
}


test()
{
    # get Redis passwordk
    REDIS_PASSWORD=$(kubectl get secret --namespace ${NAMESPACE} ${HELM_RELEASE}-redis -o jsonpath="{.data.redis-password}" | base64 --decode)

    #exec into container
    kubectl -n ${NAMESPACE} exec -it ${HELM_RELEASE}-redis-master-0 -- /bin/bash -c "redis-cli -a ${REDIS_PASSWORD} EVAL \"return {KEYS[1],KEYS[2],ARGV[1],ARGV[2]}\" 2 key1 key2 first second"
}


def harden_image()
{
    # bring down helm install
    helm delete ${HELM_RELEASE} --namespace ${NAMESPACE}

    # sleep for 5 sec
    echo "waiting for 15 sec"
    sleep 15

    # Create stub for docker image
    rfharden ${IREGISTRY}/${IREPO}:${TAG}-rfstub

    # Change tag to point to rapidfort docker account
    docker tag ${IREGISTRY}/${IREPO}:${TAG}-rfhardened ${PUB_REPO}:${TAG}

    # Push stub to our dockerhub account
    docker push ${PUB_REPO}:${TAG}

    echo "Hardened images pushed to ${PUB_REPO}:${TAG}" 
}

def main()
{
    setup

    # sleep for 3 min
    echo "waiting for 3 min"
    sleep 3m
    
    test
    
    # sleep for 25 sec
    echo "waiting for 25 sec"
    sleep 25
    
    harden_image
}

main
