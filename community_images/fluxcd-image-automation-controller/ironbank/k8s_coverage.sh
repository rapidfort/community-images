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

echo "$NAMESPACE"
echo "$RELEASE_NAME"
POD_NAME=$(kubectl -n "$NAMESPACE" get pods | grep image-automation-controller | awk '{print $1}')
# logs
kubectl logs "$POD_NAME" -n "$NAMESPACE"
# Apply the resource on the cluster
kubectl apply -f "$SCRIPTPATH"/imageupdateautomation.yaml
sleep 30
#  to see the ImageUpdateAutomation
kubectl get imagepolicy
kubectl describe imagepolicy podinfo-policy
kubectl get imagerepository
kubectl describe imagerepository podinfo
kubectl get imageupdateautomation
# to verify event
kubectl describe imageupdateautomation podinfo-update
# cleanup
kubectl delete -f "$SCRIPTPATH"/imageupdateautomation.yaml