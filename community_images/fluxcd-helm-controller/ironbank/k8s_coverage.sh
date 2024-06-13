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

POD_NAME=$(kubectl -n $NAMESPACE get pods | grep helm-controller | awk '{print $1}')

kubectl logs $POD_NAME -n $NAMESPACE



kubectl apply -f "$SCRIPTPATH"/podinfo.yml
sleep 15
kubectl get helmrelease
kubectl describe helmrelease podinfo

kubectl delete -f "$SCRIPTPATH"/podinfo.yml