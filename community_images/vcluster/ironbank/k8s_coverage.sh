#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for k8s coverage = $JSON"

NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")

# current scriptpath
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# check the version of the installed vcluster CLI
vcluster --version

# wait for 10s so that rf-vcluster-ib-0 and coredns are up and running
sleep 10

# navigate to the root directory to avoid name clash with the helm chart
cd

# creating a new vcluster seperate from the chart deployed 
vcluster create vcluster-ib -n "${NAMESPACE}"

# deleting the new vcluster
vcluster delete vcluster-ib -n "${NAMESPACE}"

# connect to the chart deployed vcluster
vcluster connect rf-vcluster-ib -n "${NAMESPACE}"

# disconnect from the vcluster
vcluster disconnect 

# pause the execution of the vcluster
vcluster pause rf-vcluster-ib -n "${NAMESPACE}"

# resume the execution of the vcluster
vcluster resume rf-vcluster-ib -n "${NAMESPACE}"

# wait until the vcluster is up and running again
kubectl wait --for=condition=ready pod/rf-vcluster-ib-0 -n "${NAMESPACE}" --timeout=120s

# Testing of the vcluster:

# add a deployment (using nginx here) to the vcluster 
kubectl apply -f "${SCRIPTPATH}"/manifests/manifest.yaml -n "${NAMESPACE}"

# get the pod name of the nginx deployment
POD_NAME=$(kubectl get pods -n "${NAMESPACE}" | grep nginx | awk '{print $1}')

# wait until the nginx pod is running
kubectl wait --for=condition=ready pod/"${POD_NAME}" -n "${NAMESPACE}" --timeout=120s

# clean up the resources
kubectl delete -f "${SCRIPTPATH}"/manifests/manifest.yaml -n "${NAMESPACE}"

# Testing complete

# list all the vclusters present in the namespace
vcluster list -n "${NAMESPACE}"

# login to vCluster.Pro
vcluster login --help -n "${NAMESPACE}"

# logout of vCluster.Pro
vcluster logout --help -n "${NAMESPACE}"

# enables vcluster telemetry 
vcluster telemetry enable -n "${NAMESPACE}"

# disables vcluster telemetry 
vcluster telemetry disable -n "${NAMESPACE}"

