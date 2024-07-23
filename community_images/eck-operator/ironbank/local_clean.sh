#!/bin/bash

set -x
# set -e

NAMESPACE=$1

kubectl delete crds -n ${NAMESPACE} --all

kubectl delete ns ${NAMESPACE}

kubectl delete clusterrole rf-eck-operator-ib rf-elastic-operator elastic-operator-edit elastic-operator-view

kubectl delete clusterrolebinding rf-eck-operator-ib

# kubectl create ns ${NAMESPACE}