#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"
NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")

CONTAINER_NAME="${NAMESPACE}"-kubectl-1


kubectl --namespace custom-namespace create secret generic rf-regcred --from-file=.dockerconfigjson=/home/runner/.docker/config.json --type=kubernetes.io/dockerconfigjson

kubectl apply -f /home/runner/work/community-images/community-images/community_images/common/cert_managet_ns.yml --namespace custom-namespace

#kubectl test coverage
docker exec -i  "$CONTAINER_NAME" ./tmp/coverage.sh