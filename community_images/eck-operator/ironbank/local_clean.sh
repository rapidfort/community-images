#!/bin/bash

set -x
set -e

NAMESPACE="eck-1"

kubectl delete crds -n ${NAMESPACE} --all

kubectl delete ns ${NAMESPACE}

kubectl delete clusterrole rf-elastic-operator elastic-operator-edit elastic-operator-view

kubectl delete clusterrolebinding rf-elastic-operator-ib

kubectl create ns ${NAMESPACE}