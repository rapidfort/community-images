#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")
RELEASE_NAME=$(jq -r '.release_name' < "$JSON_PARAMS")

kubectl port-forward service/"${RELEASE_NAME}" -n "${NAMESPACE}" 8090:80 &

sleep 10

curl http://localhost:8090