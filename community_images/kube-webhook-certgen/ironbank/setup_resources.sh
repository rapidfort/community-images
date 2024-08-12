#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Configuration for retries
max_retries=5
initial_backoff=5

# Function to check resource status with backoff
wait_for_resource() {
  local resource_check_command=$1
  local resource_name=$2
  local resource_describe_command=$3
  local retries=0
  local backoff=$initial_backoff

  until [ "$retries" -ge "$max_retries" ]; do
    if eval "$resource_check_command"; then
      echo "$(date) - $resource_name is ready."
      return 0
    else
      echo "$(date) - $resource_name is not ready. Retrying in $backoff seconds..."
      sleep "$backoff"
      retries=$((retries + 1))
      backoff=$((backoff * 2)) # Exponential backoff
    fi
  done

  echo "$(date) - $resource_name is not ready after $retries attempts."
  echo "$(date) - Fetching logs for $resource_name:"
  eval "$resource_describe_command" # Print resource logs or describe output
  return 1
}

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# Delete existing resources if they exist
kubectl delete --recursive -f "${SCRIPTPATH}"/create_resources.yml --ignore-not-found

# Apply the resources
kubectl apply --recursive -f "${SCRIPTPATH}"/create_resources.yml

# Validate the readiness of the resources

# Namespace validation
wait_for_resource \
  "[ \$(kubectl get namespace test -o jsonpath='{.status.phase}') == 'Active' ]" \
  "Namespace 'test'" \
  "kubectl describe namespace test" || exit 1

# ValidatingWebhookConfiguration validation
wait_for_resource \
  "[ \$(kubectl get validatingwebhookconfiguration pod-policy.example.com -o jsonpath='{.metadata.name}') ]" \
  "ValidatingWebhookConfiguration 'pod-policy.example.com'" \
  "kubectl describe validatingwebhookconfiguration pod-policy.example.com" || exit 1

# MutatingWebhookConfiguration validation
wait_for_resource \
  "[ \$(kubectl get mutatingwebhookconfiguration pod-policy.example.com -o jsonpath='{.metadata.name}') ]" \
  "MutatingWebhookConfiguration 'pod-policy.example.com'" \
  "kubectl describe mutatingwebhookconfiguration pod-policy.example.com" || exit 1

echo "$(date) - All resources are successfully created and ready to use."
