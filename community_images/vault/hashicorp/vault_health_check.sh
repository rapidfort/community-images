#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/scripts/bash_helper.sh

NAMESPACE=$1
RELEASE_NAME=$2

POD_NAME="rf-vault-0"
# wait for the pod to go in th running state
while [ "$(kubectl get pods "${POD_NAME}" -n "${NAMESPACE}" -o 'jsonpath={..status.phase}')" != "Running" ]; do
 echo "waiting for pod" && sleep 1;
done

# wait for the pod to be initialized
until kubectl logs "${POD_NAME}" -n "${NAMESPACE}" | grep -q "seal configuration missing"; do
  sleep 1
done