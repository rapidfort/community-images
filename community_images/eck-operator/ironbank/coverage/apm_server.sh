#!/bin/bash

set -x
set -e

NAMESPACE=$1

if [ -z "$NAMESPACE" ]; then
  echo "NAMESPACE is not set for coverage of Elasticsearch. Exiting."
  exit 1
fi
# 1p7mKtuD3MXn812f168u9qzE
# 1991065

# Get the Password for the user "apm-user"
PASSWORD=$(kubectl get secret/apm-server-apm-token -o go-template='{{index .data "secret-token" | base64decode}}' -n "${NAMESPACE}")

# Forward the host port 8200 to elastic http service port 9200 in k8s cluster
kubectl port-forward service/apm-server-apm-http 8200:8200 -n ${NAMESPACE} &
kubectl port-forward service/apm-server-apm-http 8200:8200 -n eck-1 &

# Get the PID of the background apm server process
PORT_FORWARD_PID=$!

# Sleep for 5 seconds
sleep 5

# Base URL for the apmserver
APM_BASE_URL="https://localhost:8200"

# Server information API- Get the generarl server configuration
curl -k -X POST https://127.0.0.1:8200/ \
  -H "Authorization: Bearer "${PASSWORD}""

# Agent configuration API- The APM Server agent configuration API allows you to manage configurations for agents dynamically
curl -k -X GET https://127.0.0.1:8200/config/v1/agents?service.name=test-service \
  -H "Authorization: Bearer 1p7mKtuD3MXn812f168u9qzE"

curl -k -X POST https://localhost:8200/config/v1/agents \
  -H "Authorization: Bearer 1p7mKtuD3MXn812f168u9qzE" \
  -H 'content-type: application/json' \
  -d '{"service": {"name": "test-service"}}'


