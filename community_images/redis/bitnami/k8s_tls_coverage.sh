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

# run tls script
kubectl -n "${NAMESPACE}" \
    exec -i "${HELM_RELEASE}"-master-0 \
    -- /bin/bash -c "cat /tmp/test.redis | REDISCLI_AUTH=\"${REDIS_PASSWORD}\" redis-cli -h localhost --tls --cert /opt/bitnami/redis/certs/tls.crt --key /opt/bitnami/redis/certs/tls.key --cacert /opt/bitnami/redis/certs/ca.crt --pipe"
