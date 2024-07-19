#!/bin/bash

set -x
set -e

NAMESPACE=$1

if [ -z "$NAMESPACE" ]; then
  echo "NAMESPACE is not set for coverage of Elasticsearch. Exiting."
  exit 1
fi

# Get the Password for the user "apm-user"
PASSWORD=$(kubectl get secret/kibana-kibana-user -o go-template='{{index .data "secret-token" | base64decode}}' -n "${NAMESPACE}")
# TtnsFV34594l8Doh7X6R9V8x
# Forward the host port 8200 to elastic http service port 9200 in k8s cluster
kubectl port-forward service/kibana-kb-http 8200:8200 -n ${NAMESPACE} &
kubectl port-forward service/kibana-kb-http 5601:5601 -n eck-1 &

# Get the PID of the background apm server process
PORT_FORWARD_PID=$!

# Sleep for 5 seconds
sleep 5

# Base URL for the apmserver
KIBANA_BASE_URL="https://localhost:8200"

curl -k -u elastic:TtnsFV34594l8Doh7X6R9V8x -X GET "http://localhost:5601/api/features"