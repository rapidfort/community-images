#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/scripts/bash_helper.sh

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

NAMESPACE_NAME=$(jq -r '.namespace_name' < "$JSON_PARAMS")

GITLAB_CONTAINER_REGISTRY_NAME="${NAMESPACE_NAME}-gitlab-container-registry-1"

# Get an image from docker hub
docker pull alpine:latest
# Tag the image to push to gitlab registry
docker tag alpine:latest localhost:4433/alpine:latest

# Push image to gitlab registry
docker push localhost:4433/alpine:latest
# Remove the local copy
docker rmi localhost:4433/alpine:latest
# Pull the image
docker pull localhost:4433/alpine:latest

# Use Docker v2 API to get the list of images
curl -k "https://localhost:4433/v2/_catalog"

# Get the manifest using docker API and get the digest of firstlayer in manifest
DIGEST=$(curl -k "https://localhost:4433/v2/alpine/manifests/latest" | yq -r '.layers[0].digest')
# Pull the image layer/blob as tar file
curl -k "https://localhost:4433/v2/alpine/blob/$(DIGEST)" --output "alpine_layer_0_${DIGEST}.tar"

# Cleanup - Remove the downloaded tar
rm "alpine_layer_0_${DIGEST}.tar"

# Touch binaries added along with gitlab runner
# Touch digest bin
docker exec -i "${GITLAB_CONTAINER_REGISTRY_NAME}" \
  digest --help

# Touch gomplate bin
docker exec -i "${GITLAB_CONTAINER_REGISTRY_NAME}" \
  gomplate --help

