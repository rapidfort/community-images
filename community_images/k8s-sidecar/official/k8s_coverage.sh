#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")
RELEASE_NAME=$(jq -r '.release_name' < "$JSON_PARAMS")

# details of the pod
kubectl describe pod "$RELEASE_NAME" -n "$NAMESPACE"
# logs
kubectl logs "$RELEASE_NAME" -n "$NAMESPACE"

