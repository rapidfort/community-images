if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <k8s-namespace> <tag>"
    exit 1
fi

NAMESPACE=$1 #ci-dev
TAG=$2 #6.2.6-debian-10-r95
echo "Running image generation for $0 $1 $2"

IREGISTRY=docker.io
IREPO=bitnami/redis-cluster
OREPO=rapidfort/redis-cluster-rfstub
PUB_REPO=rapidfort/redis-cluster
HELM_RELEASE=redis-cluster-release


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


test_no_tls()
{
    echo "Testing redis without TLS"
    # Install redis
    helm install ${HELM_RELEASE}  ${IREPO} --namespace ${NAMESPACE} --set image.tag=${TAG} -f overrides.yml

    # sleep for 2 min
    echo "waiting for 2 min for setup"
    sleep 2m

    # get Redis passwordk
    REDIS_PASSWORD=$(kubectl get secret --namespace ${NAMESPACE} ${HELM_RELEASE} -o jsonpath="{.data.redis-password}" | base64 --decode)

    #exec into container
    kubectl -n ${NAMESPACE} exec -it ${HELM_RELEASE}-0 -- /bin/bash -c "REDISCLI_AUTH=${REDIS_PASSWORD} redis-cli -h localhost -c EVAL \"return {KEYS[1],KEYS[2],ARGV[1],ARGV[2]}\" 2 {user1}:key1 {user1}:key2 first second"

    # sleep for 30 sec
    echo "waiting for 30 sec"
    sleep 30

    # bring down helm install
    helm delete ${HELM_RELEASE} --namespace ${NAMESPACE}

    # sleep for 30 sec
    echo "waiting for 30 sec"
    sleep 30
}


test_tls()
{
    echo "Testing redis with TLS"

    # Install certs
    kubectl apply -f tls_certs.yml

    #sleep 1 min
    echo "waiting for 1 min for setup"
    sleep 1m

    # Install redis
    helm install ${HELM_RELEASE} ${IREPO} --namespace ${NAMESPACE} --set image.tag=${TAG} --set tls.enabled=true --set tls.existingSecret=localhost-server-tls --set tls.certCAFilename=ca.crt --set tls.certFilename=tls.crt --set tls.certKeyFilename=tls.key -f overrides.yml

    # sleep for 2 min
    echo "waiting for 2 min for setup"
    sleep 2m

    # get Redis passwordk
    REDIS_PASSWORD=$(kubectl get secret --namespace ${NAMESPACE} ${HELM_RELEASE} -o jsonpath="{.data.redis-password}" | base64 --decode)

    #exec into container
    kubectl -n ${NAMESPACE} exec -it ${HELM_RELEASE}-0 -- /bin/bash -c "REDISCLI_AUTH=\"${REDIS_PASSWORD}\" redis-cli -h localhost --tls --cert /opt/bitnami/redis/certs/tls.crt --key /opt/bitnami/redis/certs/tls.key --cacert /opt/bitnami/redis/certs/ca.crt -c EVAL \"return {KEYS[1],KEYS[2],ARGV[1],ARGV[2]}\" 2 {user1}:key1 {user1}:key2 first second"

    # sleep for 30 sec
    echo "waiting for 30 sec"
    sleep 30

    # bring down helm install
    helm delete ${HELM_RELEASE} --namespace ${NAMESPACE}

    # delete certs
    kubectl delete -f tls_certs.yml

    # sleep for 30 sec
    echo "waiting for 30 sec"
    sleep 30
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
    test_no_tls
    # test_tls
    harden_image
}

main
