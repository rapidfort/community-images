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
# to produce an Artifact for a Git repository revision
kubectl apply -f "$SCRIPTPATH"/gitrepository.yml
sleep 15
kubectl get gitrepository
kubectl describe gitrepository podinfo

kubectl delete -f "$SCRIPTPATH"/gitrepository.yml

# Artifact for objects from storage solutions
kubectl apply -f "$SCRIPTPATH"/bucket.yml
sleep 15
kubectl get buckets
kubectl describe bucket minio-bucket
kubectl delete -f "$SCRIPTPATH"/bucket.yml

# Artifact for a Helm chart
kubectl apply -f "$SCRIPTPATH"/helmchart.yml
sleep 15
kubectl get helmchart
kubectl describe helmchart podinfo

kubectl delete -f "$SCRIPTPATH"/helmchart.yml

# produce an Artifact for a Helm repository index YAML
kubectl apply -f "$SCRIPTPATH"/helmrepository.yml
sleep 15
kubectl get helmrepository
kubectl describe helmrepository podinfo
kubectl delete -f "$SCRIPTPATH"/helmrepository.yml

# to produce an Artifact for an OCI repository
kubectl apply -f "$SCRIPTPATH"/ocirepository.yml
sleep 15
kubectl get ocirepository
kubectl describe ocirepository podinfo
kubectl delete -f "$SCRIPTPATH"/ocirepository.yml

