#!/bin/bash

set -x
set -e

if [[ $# -ne 4 ]]; then
    echo "Usage:$0 <server> <port> <selenium_test_dir> <k8s_namespace>"
    exit 1
fi

echo "inputs=$1 $2 $3 $4"

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

SERVER="$1"
PORT="$2"
SELENIUM_TEST_DIRECTORY="$3"
K8S_NAMESPACE="$4"

cat "${SCRIPTPATH}"/selenium_pod.yaml | envsubst - | kubectl apply -n "$K8S_NAMESPACE" -f -
