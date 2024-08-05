#!/bin/bash

set -x
set -e

NAMESPACE=$1

# Get the Prometheus Pod's names
PROMETHEUS_POD="prometheus-rf-prometheus-stack-ib-0"
_PROMETHEUS_POD="prometheus-rf-prometheus-stack-ib-prometheus-0"
PROMETHEUS_OPERATOR_POD=$(kubectl get pods -n "${NAMESPACE}" | grep rf-prometheus-stack-ib-operator | awk '{print $1}')

# wait for the Prometheus Operator to come up
kubectl wait --for=condition=ready pod/"${PROMETHEUS_OPERATOR_POD}" -n "${NAMESPACE}" --timeout=120s

# wait for the Prometheus CR to come up
kubectl wait --for=condition=ready pod/"${PROMETHEUS_POD}" -n "${NAMESPACE}" --timeout=120s || kubectl wait --for=condition=ready pod/"${_PROMETHEUS_POD}" -n "${NAMESPACE}" --timeout=120s

# sleep off for some time
sleep 10
