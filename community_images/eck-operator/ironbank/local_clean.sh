#!/bin/bash

set -x
set -e

NAMESPACE="eck"

kubectl delete crds -n ${NAMESPACE} --all

kubectl delete ns ${NAMESPACE}

kubectl delete clusterrole elastic-operator elastic-operator-edit elastic-operator-view

kubectl create ns ${NAMESPACE}