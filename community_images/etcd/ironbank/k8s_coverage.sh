#!/bin/bash

set -x
set -e

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

JSON_PARAMS="$1"

NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")
RELEASE_NAME=$(jq -r '.release_name' < "$JSON_PARAMS")

# get pod name
POD_NAME="${RELEASE_NAME}"-0

# etcd password
ROOT_PASSWORD=$(kubectl get secret --namespace "${NAMESPACE}" "${RELEASE_NAME}" -o jsonpath="{.data.etcd-root-password}" | base64 -d)

# copy etcd_test.sh into container
kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/etcd_test.sh "${POD_NAME}":/tmp/etcd_test.sh

# run etcd_test on cluster
kubectl -n "${NAMESPACE}" exec -i "${POD_NAME}" -- /bin/bash -c "/tmp/etcd_test.sh $ROOT_PASSWORD"
