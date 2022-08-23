#!/bin/bash

set -x
set -e

if [[ $# -ne 4 ]]; then
    echo "Usage:$0 <server> <port> <selenium_test_dir> <k8s_namespace>"
    exit 1
fi

echo "inputs=$1 $2 $3 $4"

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

export SERVER="$1"
export PORT="$2"
export SELENIUM_TEST_DIRECTORY="$3"
export K8S_NAMESPACE="$4"

envsubst < "${SCRIPTPATH}"/selenium_job.yml > "${SCRIPTPATH}"/selenium_job_env.yml

kubectl -n "$K8S_NAMESPACE" delete job python-chromedriver --ignore-not-found=true

kubectl apply -n "$K8S_NAMESPACE" -f "${SCRIPTPATH}"/selenium_job_env.yml

set +e
kubectl -n "$K8S_NAMESPACE" wait --for=condition=complete job/python-chromedriver --timeout=3m
set -e

kubectl -n "$K8S_NAMESPACE" get pods

kubectl -n "$K8S_NAMESPACE" logs -l job-name=python-chromedriver

kubectl -n "$K8S_NAMESPACE" delete job python-chromedriver

rm -f "${SCRIPTPATH}"/selenium_job_env.yml
