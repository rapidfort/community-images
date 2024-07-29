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

# fetching kafka-exporter pod name
KAFKA_EXPORTER_POD_NAME=$(kubectl get pods --no-headers -n "${NAMESPACE}" | grep '^rf-kafka-exporter-ib-exporter-0' | awk '{print $1}')
echo "Kafka Exporter Pod Name = ${KAFKA_EXPORTER_POD_NAME}"

# copy over the script to the kafka pod
kubectl cp "${SCRIPTPATH}"/k8s_coverage_helper.sh \
  rf-kafka-exporter-ib-0:/opt/bitnami/kafka/k8s_coverage_helper.sh \
  -n "${NAMESPACE}"

# execute the script in the kafka pod
kubectl exec -i rf-kafka-exporter-ib-0 -n "${NAMESPACE}" -- bash ./opt/bitnami/kafka/k8s_coverage_helper.sh

# check the corresponding logs in kafka-exporter
kubectl exec -i "${KAFKA_EXPORTER_POD_NAME}" -n "${NAMESPACE}" -- bash -c "curl http://localhost:9308/metrics"