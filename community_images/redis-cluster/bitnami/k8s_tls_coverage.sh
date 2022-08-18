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
    "${SCRIPTPATH}"/../../common/tests/test.redis \
    "${RELEASE_NAME}"-0:/tmp/test.redis

# copy redis_cluster_runner.sh into container
kubectl -n "${NAMESPACE}" cp \
    "${SCRIPTPATH}"/redis_cluster_runner.sh \
    "${RELEASE_NAME}"-0:/tmp/redis_cluster_runner.sh

# run redis_cluster_runner on cluster
kubectl -n "${NAMESPACE}" exec \
    -i "${RELEASE_NAME}"-0 \
    -- /bin/bash -c \
    "/tmp/redis_cluster_runner.sh ${REDIS_PASSWORD} ${RELEASE_NAME} /tmp/test.redis --tls --cert /opt/bitnami/redis/certs/tls.crt --key /opt/bitnami/redis/certs/tls.key --cacert /opt/bitnami/redis/certs/ca.crt"

# copy redis_coverage.sh into container
kubectl -n "${NAMESPACE}" cp \
    "${SCRIPTPATH}"/../../common/tests/redis_coverage.sh \
    "${RELEASE_NAME}"-0:/tmp/redis_coverage.sh

# run redis_coverage command on cluster
kubectl -n "${NAMESPACE}" exec \
    -i "${RELEASE_NAME}"-0 -- /bin/bash -c \
    "/tmp/redis_coverage.sh"
