#!/bin/bash

set -x
set -e

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/scripts/bash_helper.sh


JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")
echo "Json params for k8s coverage = $JSON"
NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")
RELEASE_NAME=$(jq -r '.release_name' < "$JSON_PARAMS")
echo "NAMESPACE: $NAMESPACE"
echo "RELEASE_NAME: $RELEASE_NAME"

sleep 10

CONTAINER_NAME="$RELEASE_NAME"

kubectl exec -n "${NAMESPACE}" "${CONTAINER_NAME}" -- /bin/bash -c "/fluent-bit/bin/fluent-bit -c /etc/fluent-bit.conf" &
sleep 10
# Check if the process is still running and terminate it if needed
if ps -p $! > /dev/null; then
    echo "Fluent Bit process is still running. Terminating..."
    kill $!
fi
