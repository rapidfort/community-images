#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for k8s coverage = $JSON"

NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")

# Define the names for the pods
PROMETHEUS_CR_NAME="rf-prometheus-stack-ib"
RELOADER_POD="prometheus-rf-prometheus-stack-ib-0"

# Create Secret with additional scrape configs
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: additional-scrape-configs
  namespace: "${NAMESPACE}"
stringData:
  additional-scrape-configs.yaml: |
    - job_name: "test-job"
      static_configs:
        - targets: ["localhost:9090"]
EOF

# Apply a patch to the prometheus CR to trigger a configuration change
kubectl patch prometheus "${PROMETHEUS_CR_NAME}" -n "${NAMESPACE}" --type='json' -p='[
  {
    "op": "add",
    "path": "/spec/additionalScrapeConfigs",
    "value": {
      "key": "additional-scrape-configs.yaml",
      "name": "additional-scrape-configs"
    }
  }
]'

# Waiting for prometheus-config-reloader to detect changes and trigger reload...
echo "Waiting for prometheus-config-reloader to detect changes and trigger reload..."

# Define the maximum total wait time (in seconds)
MAX_WAIT_TIME=600  # 10 minutes

# Initialize the start time
START_TIME=$(date +%s)

while true; do
  # Fetch the latest log
  LOG_OUTPUT=$(kubectl logs "${RELOADER_POD}" -c config-reloader -n "${NAMESPACE}" --tail=1)
  
  # Check whether the log contains "Reload triggered" as substring or not
  if [[ ! "$LOG_OUTPUT" == *"Reload triggered"* ]]; then
    echo "Log is not of 'Reload triggered' type."
    continue
  fi

  # Extract the timestamp from the log
  LOG_TIMESTAMP=$(echo "$LOG_OUTPUT" | grep -oP 'ts=\K[0-9T:\.-]+Z')

  # Get the current timestamp in the same format
  CURRENT_TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S.%NZ")
  
  # Convert both timestamps to seconds since epoch
  LOG_SECONDS=$(date -d "$LOG_TIMESTAMP" +%s)
  CURRENT_SECONDS=$(date -d "$CURRENT_TIMESTAMP" +%s)
  
  # Calculate the difference in seconds
  DIFF_SECONDS=$((CURRENT_SECONDS - LOG_SECONDS))
  
  # Check if the difference is less than 10 seconds
  if [ "$DIFF_SECONDS" -lt 10 ]; then
    echo "Configuration reload detected."
    break
  fi
  
  # Check if the total elapsed time exceeds the maximum wait time
  CURRENT_TIME=$(date +%s)
  ELAPSED_TIME=$((CURRENT_TIME - START_TIME))
  if [ "$ELAPSED_TIME" -ge "$MAX_WAIT_TIME" ]; then
    echo "Maximum wait time exceeded. Exiting the script."
    exit 1
  fi
  
  # Wait for a short period before checking again
  sleep 1
done

# Clean up- Delete the secret additional-scrape-configs
kubectl delete secret additional-scrape-configs -n "$NAMESPACE"