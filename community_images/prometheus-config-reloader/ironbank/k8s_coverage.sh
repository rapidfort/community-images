#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for k8s coverage = $JSON"

NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")
RELEASE_NAME=$(jq -r '.release_name' < "$JSON_PARAMS")

PROMETHEUS_CR_NAME="prometheus-stack-kube-prom-prometheus"
RELOADER_POD=$(kubectl get pods -n $NAMESPACE -l app=prometheus,component=server -o jsonpath="{.items[0].metadata.name}")

# Create Secret with additional scrape configs
echo "Creating Secret with additional scrape configs for prometheus..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: additional-scrape-configs
  namespace: ${NAMESPACE}
stringData:
  additional-scrape-configs.yaml: |
    - job_name: "test-job"
      static_configs:
        - targets: ["localhost:9090"]
EOF

# Apply a patch to the prometheus CR to trigger a configuration change
kubectl patch prometheus ${PROMETHEUS_CR_NAME} -n ${NAMESPACE} --type='json' -p='[
  {
    "op": "add",
    "path": "/spec/additionalScrapeConfigs",
    "value": {
      "key": "additional-scrape-configs.yaml",
      "name": "additional-scrape-configs"
    }
  }
]'

# Sleep for 10 seconds to make sure prometheus-config-reloader updates the configuration of the prometheus CR
sleep 10

echo "Waiting for prometheus-config-reloader to detect changes and trigger reload..."
kubectl logs -n $NAMESPACE $RELOADER_POD -c config-reloader -f | while read LOGLINE
do
    [[ "${LOGLINE}" == *"Config reloader triggered"* ]] && pkill -P $$ tail
done
echo "Configuration reload detected."

# Clean up- Delete the secret additional-scrape-configs
kubectl delete secret additional-scrape-configs -n $NAMESPACE