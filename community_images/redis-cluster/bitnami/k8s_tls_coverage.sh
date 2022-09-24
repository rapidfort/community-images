#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")
RELEASE_NAME=$(jq -r '.release_name' < "$JSON_PARAMS")

# get Redis passwordk
REDIS_PASSWORD=$(kubectl get secret --namespace "${NAMESPACE}" "${RELEASE_NAME}" -o jsonpath="{.data.redis-password}" | base64 --decode)

# run redis_cluster_runner on cluster
kubectl -n "${NAMESPACE}" exec \
    -i "${RELEASE_NAME}"-0 \
    -- /bin/bash -c \
    "REDISCLI_AUTH=${REDIS_PASSWORD} redis-cli -h ${RELEASE_NAME} -p 6379 --tls --cert /opt/bitnami/redis/certs/tls.crt --key /opt/bitnami/redis/certs/tls.key --cacert /opt/bitnami/redis/certs/ca.crt -c ping"
