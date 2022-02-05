
IREGISTRY=docker.io
IREPO=bitnami/redis
TAG=6.2.6-debian-10-r103
OREPO=rapidfort/redis-rfstub
HELM_RELEASE=stub-run-release
NAMESPACE=ci-dev

# Pull docker image
docker pull ${IREGISTRY}/${IREPO}:${TAG}
# Create stub for docker image
rfstub ${IREGISTRY}/${IREPO}:${TAG}

# Change tag to point to rapidfort docker account
docker tag ${IREGISTRY}/${IREPO}:${TAG}-rfstub ${OREPO}:${TAG}

# Push stub to our dockerhub account
docker push ${OREPO}:${TAG}


helm install ${HELM_RELEASE}  ${IREPO} --namespace ${NAMESPACE} --set image.tag=${TAG} -f overrides.yml


