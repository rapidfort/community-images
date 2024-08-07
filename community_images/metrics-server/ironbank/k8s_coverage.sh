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
POD_NAME=$(kubectl get pod -n "${NAMESPACE}" | grep "${RELEASE_NAME}-[a-z0-9-]*" -o)

# Adding Cleanup Trap for php-apache Release

trap '${SCRIPTPATH}/cleanup_script.sh' EXIT

# Running Kubectl Top Commands

kubectl --namespace "${NAMESPACE}" top pod
kubectl --namespace "${NAMESPACE}" top pod "${POD_NAME}"
kubectl --namespace "${NAMESPACE}" top node

# Creating a PHP Deployment and Service

kubectl create deployment php-apache --image=k8s.gcr.io/hpa-example
kubectl patch deployment php-apache -p='{"spec":{"template":{"spec":{"containers":[{"name":"hpa-example","resources":{"requests":{"cpu":"200m"}}}]}}}}'
kubectl create service clusterip php-apache --tcp=80

# Autoscaling the deployment

kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10

# Check the HPA status

kubectl get hpa
