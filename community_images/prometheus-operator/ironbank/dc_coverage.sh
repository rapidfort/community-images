#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# Create the namespace and CRDs, and then wait for them to be availble before creating the remaining resources
kubectl create -f "${SCRIPTPATH}"/manifests/setup
sleep 10

# Wait until the "servicemonitors" CRD is created. The message "No resources found" means success in this context.
until kubectl get servicemonitors --all-namespaces ; do date; sleep 1; echo ""; done
sleep 10

# creating the resources
kubectl create -f "${SCRIPTPATH}"/manifests/
sleep 10

# wait for pod to be running
timeout=300  # 5 minutes timeout
end=$((SECONDS+timeout))

until kubectl get pods -n monitoring -l app.kubernetes.io/name=prometheus -o jsonpath='{.items[0].status.phase}' | grep -q Running || [ $SECONDS -ge $end ]; do
  echo "Waiting for Prometheus pod to be Running..."
  sleep 5
done

if [ $SECONDS -ge $end ]; then
  echo "Timeout waiting for Prometheus pod to be Running"
  exit 1
else
  echo "Prometheus pod is now Running. Starting port-forward..."
fi

# Function to wait for pod readiness
wait_for_pod() {
  echo "Waiting for $1 pod to be ready..."
  kubectl wait --for=condition=ready pod -l app.kubernetes.io/name="$1" -n monitoring --timeout=300s
}

# Function to perform port-forward and curl
port_forward_and_curl() {
  kubectl --namespace monitoring port-forward svc/"$1" "$2":"$2" &
  PF_PID=$!
  sleep 5  # Give it some time to establish the connection

  curl -s http://localhost:"$2"/ || echo "Failed to curl $1"

  if [[ "$1" == "prometheus-k8s" ]]; then
    curl -s http://localhost:"$2"/alerts || echo "Failed to curl $1 alerts"
    curl -s http://localhost:"$2"/rules || echo "Failed to curl $1 rules"
  fi

  kill "$PF_PID"
}

# Wait for pods to be ready
wait_for_pod "prometheus"
wait_for_pod "alertmanager"
wait_for_pod "grafana"

# Access Prometheus
port_forward_and_curl "prometheus-k8s" 9090

# Access Alertmanager
port_forward_and_curl "alertmanager-main" 9093

# Access Grafana
port_forward_and_curl "grafana" 3000

# cleanup image
kubectl delete --ignore-not-found=true -f "${SCRIPTPATH}"/manifests/ -f "${SCRIPTPATH}"/manifests/setup