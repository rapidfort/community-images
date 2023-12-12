#!/bin/bash

set -x
set -e

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/scripts/bash_helper.sh


JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")
RELEASE_NAME=$(jq -r '.release_name' < "$JSON_PARAMS")
echo "NAMESPACE: $NAMESPACE"
echo "RELEASE_NAME: $RELEASE_NAME"

sleep 60
CONTAINER_NAME="${RELEASE_NAME}-0"
# copy over the script to the pod
kubectl cp "${SCRIPTPATH}"/scripts/fluent-bit_coverage_script.sh "${CONTAINER_NAME}":/tmp/fluent-bit_cvoverage_script.sh -n "${NAMESPACE}"

test_fluent-bit "${CONTAINER_NAME}" "${NAMESPACE}" "yes"