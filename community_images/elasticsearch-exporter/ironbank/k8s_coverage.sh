#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for k8s coverage = $JSON"

# NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")
# RELEASE_NAME=$(jq -r '.release_name' < "$JSON_PARAMS")
