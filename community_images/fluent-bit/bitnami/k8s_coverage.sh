#!/bin/bash

set -x
set -e

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/scripts/bash_helper.sh

JSON_PARAMS="$1"
#JSON=$(cat "$JSON_PARAMS")
NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")
RELEASE_NAME=$(jq -r '.release_name' < "$JSON_PARAMS")
CONTAINER_NAME=$(kubectl get pods -n "$NAMESPACE" -l "app.kubernetes.io/instance=$RELEASE_NAME" -o jsonpath='{.items[0].metadata.name}')
# copy over the script to the pod
kubectl exec "${CONTAINER_NAME}" -n "${NAMESPACE}" -- /bin/bash -c "nohup /opt/bitnami/fluent-bit/bin/fluent-bit -c /opt/bitnami/fluent-bit/conf/fluent-bit.conf" &
sleep 10
# Check if the process is still running and terminate it if needed
if ps -p $! > /dev/null; then
    echo "Fluent Bit process is still running. Terminating..."
    kill $!
fi