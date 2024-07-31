#!/bin/bash

set -x
set -e

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for k8s coverage = $JSON"

NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")
RELEASE_NAME=$(jq -r '.release_name' < "$JSON_PARAMS")

POD_NAME=$(kubectl get pods -n $NAMESPACE | grep "${RELEASE_NAME}-gitlab-exporter" | awk '{ print $1 }')

kubectl exec -i "${POD_NAME}" -n "${NAMESPACE}" -- bash -c "curl localhost:9168/git_process"

kubectl exec -i "${POD_NAME}" -n "${NAMESPACE}" -- bash -c "curl localhost:9168/process"

kubectl exec -i "${POD_NAME}" -n "${NAMESPACE}" -- bash -c "curl localhost:9168/database"

kubectl exec -i "${POD_NAME}" -n "${NAMESPACE}" -- bash -c "curl localhost:9168/sidekiq"

kubectl exec -i "${POD_NAME}" -n "${NAMESPACE}" -- bash -c "curl localhost:9168/metrics"