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
    "${SCRIPTPATH}"/../../common/tests/test.redis "${RELEASE_NAME}"-master-0:/tmp/test.redis

# run script
kubectl -n "${NAMESPACE}" \
    exec -i "${RELEASE_NAME}"-master-0 \
    -- /bin/bash -c "cat /tmp/test.redis | REDISCLI_AUTH=\"${REDIS_PASSWORD}\" redis-cli -h localhost --pipe"

kubectl run "${RELEASE_NAME}"-client --rm -i \
    --restart='Never' --namespace "${NAMESPACE}" \
    --image rapidfort/redis --command \
    -- redis-benchmark -h "${RELEASE_NAME}"-master -p 6379 -a "$REDIS_PASSWORD" -n 1000 -c 10
