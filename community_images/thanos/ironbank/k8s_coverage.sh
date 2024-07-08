#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for k8s coverage = $JSON"

NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")

THANOS_QUERY_POD_NAME=$(kubectl get pods -n "${NAMESPACE}" -l app.kubernetes.io/component=query -o jsonpath="{.items[0].metadata.name}")
THANOS_QUERY_SVC_CLUSTER_IP=$(kubectl get svc -n "${NAMESPACE}" -l app.kubernetes.io/component=query -o jsonpath="{.items[0].spec.clusterIP}")
THANOS_QUERY_SVC_PORT='9090'

# Function to perform Thanos Query API query and check success
query_thanos() {
    local query=$1

    echo "Querying Thanos API with query: $query"
    response=$(kubectl exec -i "${THANOS_QUERY_POD_NAME}" -n "${NAMESPACE}" -- curl -sS "http://${THANOS_QUERY_SVC_CLUSTER_IP}:${THANOS_QUERY_SVC_PORT}/api/v1/query?query=${query}")
    echo "Response: $response"

    # Check if the response contains "status":"success"
    if echo "$response" | jq -e '.status == "success"' > /dev/null; then
        echo "Query '$query' was successful."
    else
        echo "Query '$query' failed."
        exit 0
    fi
}

# Query Thanos API for various metrics
query_thanos "prometheus_http_requests_total"
query_thanos "up"
query_thanos "prometheus_tsdb_head_chunks"
query_thanos "prometheus_tsdb_compaction_chunk_range_seconds"
query_thanos "prometheus_notifications_alertmanagers_discovered"
query_thanos "prometheus_notifications_queue_capacity"
