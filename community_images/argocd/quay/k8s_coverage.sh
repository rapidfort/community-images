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
POD_NAME=$(kubectl get pod -n "${NAMESPACE}" | grep "${RELEASE_NAME}-server[a-z0-9-]*"  --color=auto -o)

ARGOCD_SERVER=$(kubectl get svc -n "${NAMESPACE}" "${RELEASE_NAME}-server" -o json | jq '.spec.clusterIP')
ARGOCD_PORT='443'

# Create testing namespace
kubectl create namespace argocd

sleep 20

kubectl cp "${SCRIPTPATH}"/coverage.sh "${POD_NAME}":/home/argocd/coverage.sh -n "${NAMESPACE}"

kubectl exec -i "${POD_NAME}" -n "${NAMESPACE}" -- bash -c "./coverage.sh pass_123" 

"${SCRIPTPATH}"/../../common/selenium_tests/runner.sh "${ARGOCD_SERVER}" "${ARGOCD_PORT}" "${SCRIPTPATH}"/selenium_tests "${NAMESPACE}" 2>&1
