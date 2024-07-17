#!/bin/bash

set -x
set -e


JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for k8s coverage = $JSON"

NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")
RELEASE_NAME=$(jq -r '.release_name' < "$JSON_PARAMS")
POD_NAME=$(kubectl get pod -n "${NAMESPACE}" | grep "${RELEASE_NAME}[a-z0-9-]*"  --color=auto -o)

kubectl exec -i "${POD_NAME}" -c tempo-query -n "${NAMESPACE}"  -- bash -c "./go/bin/query-linux print-config"

kubectl exec -i "${POD_NAME}" -c tempo-query -n "${NAMESPACE}"  -- bash -c "./go/bin/query-linux completion bash"

kubectl exec -i "${POD_NAME}" -c tempo-query -n "${NAMESPACE}"  -- bash -c "./tempo-query" || echo 0

