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
POD_NAME=$(kubectl get pod -n "${NAMESPACE}" | grep "${RELEASE_NAME}-[a-z0-9-]*"  --color=auto -o)



sleep 40

kubectl exec -i  "${POD_NAME}" -n "${NAMESPACE}" -- bash -c "cat > ./coverage.sh" < "${SCRIPTPATH}/coverage.sh"
kubectl exec -i  "${POD_NAME}" -n "${NAMESPACE}" -- bash -c "chmod u+x ./coverage.sh"
kubectl exec -i  "${POD_NAME}" -n "${NAMESPACE}" -- bash -c "./coverage.sh"


# Delete CRDs
kubectl delete crds -l component=velero.io


