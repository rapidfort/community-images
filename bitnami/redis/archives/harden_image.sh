IREGISTRY=docker.io
IREPO=bitnami/redis
TAG=6.2.6-debian-10-r103
OREPO=rapidfort/redis
HELM_RELEASE=stub-run-release
NAMESPACE=ci-dev

# bring down helm install
helm delete ${HELM_RELEASE} --namespace ${NAMESPACE}


# Create stub for docker image
rfharden ${IREGISTRY}/${IREPO}:${TAG}-rfstub

# Change tag to point to rapidfort docker account
docker tag ${IREGISTRY}/${IREPO}:${TAG}-rfhardened ${OREPO}:${TAG}

# Push stub to our dockerhub account
docker push ${OREPO}:${TAG}
