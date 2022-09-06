#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

SCRIPTPATH=$(jq -r '.image_script_dir' < "$JSON_PARAMS")
NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")
RELEASE_NAME=$(jq -r '.release_name' < "$JSON_PARAMS")

# get Redis passwordk
REDIS_PASSWORD=$(kubectl get secret --namespace "${NAMESPACE}" "${RELEASE_NAME}" -o jsonpath="{.data.redis-password}" | base64 --decode)

# copy test.redis into container
kubectl -n "${NAMESPACE}" cp \
    "${SCRIPTPATH}"/test.redis \
    "${RELEASE_NAME}"-0:/tmp/test.redis

# copy redis_cluster_runner.sh into container
kubectl -n "${NAMESPACE}" cp \
    "${SCRIPTPATH}"/redis_cluster_runner.sh \
    "${RELEASE_NAME}"-0:/tmp/redis_cluster_runner.sh

# run command on cluster
kubectl -n "${NAMESPACE}" exec \
    -i "${RELEASE_NAME}"-0 -- /bin/bash -c \
    "/tmp/redis_cluster_runner.sh ${REDIS_PASSWORD} ${RELEASE_NAME} /tmp/test.redis"

# run benchmark
kubectl run "${RELEASE_NAME}"-client --rm -i \
    --restart='Never' --namespace "${NAMESPACE}" \
    --image rapidfort/redis-cluster --command \
    -- redis-benchmark -h "${RELEASE_NAME}" -c 10 -n 1000 -a "$REDIS_PASSWORD" --cluster

function finish {
    kubectl get pods --all-namespaces
    kubectl get services --all-namespaces
}
trap finish EXIT