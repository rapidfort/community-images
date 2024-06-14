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

#creating ImageRepository resource for image-reflector
kubectl apply -f "$SCRIPTPATH"/imagerepository.yaml
sleep 15
# lists all ImageRepository resources in the Kubernetes cluster
kubectl get imagerepository
kubectl describe imagerepository podinfo
# policies for automating updates based on the ImageRepository
kubectl apply -f "$SCRIPTPATH"/imagepolicy.yaml
sleep 15

kubectl get imagepolicy
# status and any conditions set by the FluxCD Image Reflector Controller
kubectl describe imagepolicy podinfo
# cleanup
kubectl delete -f "$SCRIPTPATH"/imagerepository.yaml
kubectl delete -f "$SCRIPTPATH"/imagepolicy.yaml