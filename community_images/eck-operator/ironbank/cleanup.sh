#!/bin/bash

set -x
set -e

NAMESPACE=$1
RELEASE_NAME=$2

kubectl delete pods ${RELEASE_NAME} -n ${NAMESPACE}

kubectl delete crds -n ${NAMESPACE} --all

helm uninstall -n ${NAMESPACE} ${RELEASE_NAME}