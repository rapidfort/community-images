#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

SCRIPTPATH=$(jq -r '.image_script_dir' < "$JSON_PARAMS")
NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")
RELEASE_NAME=$(jq -r '.release_name' < "$JSON_PARAMS")

# get Redis password
REDIS_PASSWORD=$(kubectl get secret --namespace "${NAMESPACE}" "${RELEASE_NAME}" -o jsonpath="{.data.redis-password}" | base64 --decode)

# copy test.redis into container
kubectl -n "${NAMESPACE}" cp \
    "${SCRIPTPATH}"/../../common/tests/test.redis "${RELEASE_NAME}"-master-0:/tmp/test.redis

# run script
kubectl -n "${NAMESPACE}" \
    exec -i "${RELEASE_NAME}"-master-0 \
    -- /bin/bash -c "cat /tmp/test.redis | REDISCLI_AUTH=\"${REDIS_PASSWORD}\" redis-cli -h localhost --pipe"

# copy redis_coverage.sh into container
kubectl -n "${NAMESPACE}" cp \
    "${SCRIPTPATH}"/../../common/tests/redis_coverage.sh \
    "${RELEASE_NAME}"-master-0:/tmp/redis_coverage.sh

# run redis_coverage command on cluster
kubectl -n "${NAMESPACE}" exec \
    -i "${RELEASE_NAME}"-master-0 -- /bin/bash -c \
    "/tmp/redis_coverage.sh"


kubectl run "${RELEASE_NAME}"-client --restart='Never' --namespace "${NAMESPACE}" \
    --image bitnami/redis --command -- sleep infinity
kubectl wait pod "${RELEASE_NAME}"-client --for=condition=ready --timeout=10m -n "${NAMESPACE}"
kubectl exec -it "${RELEASE_NAME}"-client -n "${NAMESPACE}" -- \
    redis-benchmark -h "${RELEASE_NAME}"-master -p 6379 -a "${REDIS_PASSWORD}" -n 1000 -c 10

# # run redis benchmark
# kubectl run "${RELEASE_NAME}"-client --rm -i \
#     --restart='Never' --namespace "${NAMESPACE}" \
#     --image rapidfort/redis --command \
#     -- redis-benchmark -h "${RELEASE_NAME}"-master -p 6379 -a "${REDIS_PASSWORD}" -n 1000 -c 10