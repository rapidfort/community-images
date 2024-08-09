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
TOKEN=$(head -c 12 /dev/urandom | shasum | cut -d ' ' -f1)
POD_NAME=$(kubectl -n "$NAMESPACE" get pods | grep notification-controller | awk '{print $1}')
# logs
kubectl logs "$POD_NAME" -n "$NAMESPACE"
# Create a secret in the specified namespace
kubectl create secret generic receiver-token --from-literal=token="$TOKEN"
# applying an incoming webhook receiver
kubectl apply -f "${SCRIPTPATH}"/github-reciever.yaml

# Wait for the resources to be created
sleep 10
# Describe the receiver resource to verify
kubectl describe receiver github-receiver
kubectl get receivers
# cleanup
kubectl delete secret receiver-token
kubectl delete -f "${SCRIPTPATH}/github-reciever.yaml"
# testing to send alerts
kubectl apply -f "${SCRIPTPATH}"/slack-alerts.yaml
sleep 10
kubectl get provider slack-bot -n default
kubectl get alert slack -n default
# cleanup
kubectl delete -f "${SCRIPTPATH}/slack-alerts.yaml"
# Delete CRDs
kubectl delete crd receivers.notification.toolkit.fluxcd.io &
PID_CRD=$!

sleep 5
kill "${PID_CRD}" || true

kubectl patch crd/receivers.notification.toolkit.fluxcd.io -p '{"metadata":{"finalizers":[]}}' --type=merge || true