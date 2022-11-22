#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for k8s coverage = $JSON"

SCRIPTPATH=$(jq -r '.image_script_dir' < "$JSON_PARAMS")
NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")
RELEASE_NAME=$(jq -r '.release_name' < "$JSON_PARAMS")

YOURLS_SERVER="${RELEASE_NAME}"."${NAMESPACE}".svc.cluster.local
YOURLS_PORT='8080'

