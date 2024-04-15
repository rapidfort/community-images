#!/bin/bash

set -x
set -e

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for k8s coverage = $JSON"

NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")

sleep 60

# copy over the script to the pod
kubectl cp "${SCRIPTPATH}"/k8s_coverage_helper.sh \
  rf-kafka-ib-0:/opt/bitnami/kafka/k8s_coverage_helper.sh \
  -n "${NAMESPACE}"

kubectl exec -i rf-kafka-ib-0 -n ${NAMESPACE} -- bash ./opt/bitnami/kafka/k8s_coverage_helper.sh
