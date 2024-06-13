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


kubectl apply -f "$SCRIPTPATH"/imageupdateautomation.yaml
sleep 30

kubectl get imagepolicy
kubectl describe imagepolicy podinfo-policy
kubectl get imagerepository
kubectl describe imagerepository podinfo
kubectl get imageupdateautomation
kubectl describe imageupdateautomation podinfo-update

kubectl delete -f "$SCRIPTPATH"/imageupdateautomation.yaml