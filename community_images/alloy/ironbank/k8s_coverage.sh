#!/bin/bash

set -x
set -e

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for k8s coverage = $JSON"

NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")
RELEASE_NAME=$(jq -r '.release_name' < "$JSON_PARAMS")
POD_NAME=$(kubectl get pod -n "${NAMESPACE}" | grep "${RELEASE_NAME}-[a-z0-9-]*"  --color=auto -o)


kubectl exec -i "${POD_NAME}" -n "${NAMESPACE}" -- bash -c "cat > /tmp/prometheus.yaml" <<EOF
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node_exporter'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9100']
EOF


kubectl exec -i "${POD_NAME}" -n "${NAMESPACE}" -- bash -c "cat > ./tmp/coverage.sh" < "${SCRIPTPATH}/coverage.sh"
kubectl exec -i "${POD_NAME}" -n "${NAMESPACE}" -- bash -c "chmod u+x ./tmp/coverage.sh"
kubectl exec -i "${POD_NAME}" -n "${NAMESPACE}" -- bash -c "./tmp/coverage.sh"


