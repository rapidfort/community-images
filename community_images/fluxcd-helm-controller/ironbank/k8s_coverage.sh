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
echo "$RELEASE_NAME"
POD_NAME=$(kubectl -n "$NAMESPACE" get pods | grep helm-controller | awk '{print $1}')
# logs
kubectl logs "$POD_NAME" -n "$NAMESPACE"
# applying HelmRelease
kubectl apply -f "$SCRIPTPATH"/podinfo.yml
sleep 15
# to see the HelmRelease status
kubectl get helmrelease
# to check helm-controller have worked
kubectl describe helmrelease podinfo
# cleanup
kubectl delete -f "$SCRIPTPATH"/podinfo.yml