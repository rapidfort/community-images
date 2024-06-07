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

sleep 40

kubectl exec -i "${POD_NAME}" -n "${NAMESPACE}" -- bash -c "cat > ./coverage.sh" < "${SCRIPTPATH}/coverage.sh"
kubectl exec -i "${POD_NAME}" -n "${NAMESPACE}" -- bash -c "chmod u+x ./coverage.sh"
kubectl exec -i "${POD_NAME}" -n "${NAMESPACE}" -- bash -c "./coverage.sh pass_123"

("${SCRIPTPATH}"/../../common/selenium_tests/runner.sh "${ARGOCD_SERVER}" "${ARGOCD_PORT}" "${SCRIPTPATH}"/selenium_tests "${NAMESPACE}" 2>&1) >&2
# Delete CRDs
kubectl delete crd applications.argoproj.io applicationsets.argoproj.io appprojects.argoproj.io &
PID_CRD=$!

sleep 5
kill "${PID_CRD}" || true

kubectl patch crd/applications.argoproj.io -p '{"metadata":{"finalizers":[]}}' --type=merge || true

kubectl delete namespace argocd
