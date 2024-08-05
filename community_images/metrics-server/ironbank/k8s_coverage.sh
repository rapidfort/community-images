#!/bin/bash

set -x
set -e

# Getting Runtime Parameters
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
JSON_PARAMS="$1"
JSON=$(cat "$JSON_PARAMS")

echo "Json Params for k8s coverage = $JSON"

NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")
RELEASE_NAME=$(jq -r '.release_name' < "$JSON_PARAMS")
POD_NAME=$(kubectl get pod -n "${NAMESPACE}" | grep "${RELEASE_NAME}-[a-z0-9-]*"  --color=auto -o)

# Running Commands
kubectl --namespace "${NAMESPACE}" top pod
kubectl --namespace "${NAMESPACE}" top node
kubectl get hpa