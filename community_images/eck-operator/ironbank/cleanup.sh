#!/bin/bash

set -x
set -e

NAMESPACE=$1
# kubectl delete pods ${RELEASE_NAME} -n ${NAMESPACE}

kubectl delete crds -n ${NAMESPACE} --all

helm uninstall -n ${NAMESPACE} rf-eck-operator-ib

kubectl delete ns ${NAMESPACE}
