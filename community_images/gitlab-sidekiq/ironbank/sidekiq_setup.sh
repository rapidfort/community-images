#!/bin/bash

set -e
set -x

NAMESPACE=$1
RELEASE_NAME=$2
POD_NAME=$(kubectl get pods -n $NAMESPACE | grep "${RELEASE_NAME}-sidekiq-all-in-1-v2" | awk '{ print $1}')
CONTAINER_NAME="sidekiq"
TIMEOUT=1200  # seconds
INTERVAL=5   # seconds

# Wait for sidekiq pod to be in the running and ready state
kubectl wait -n $NAMESPACE --for=condition=Ready pod/$POD_NAME --timeout=${TIMEOUT}s

# Check sidekiq container's status
end=$((SECONDS + TIMEOUT))

while (( SECONDS < end )); do
    CONTAINER_STATUS=$(kubectl get pod $POD_NAME -n $NAMESPACE -o jsonpath="{.status.containerStatuses[?(@.name=='$CONTAINER_NAME')]}")
    CONTAINER_READY=$(echo $CONTAINER_STATUS | jq -r '.ready')

    if [[ "$CONTAINER_READY" == true ]]; then
        echo "Container $CONTAINER_NAME in pod $POD_NAME is running and ready"
        exit 0
    else
        echo "Waiting for container $CONTAINER_NAME in pod $POD_NAME to be running and ready..."
        sleep $INTERVAL
    fi
done

echo "Timed out waiting for container $CONTAINER_NAME in pod $POD_NAME to be running and ready"
exit 1