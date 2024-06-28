#!/bin/bash

set -x
set -e

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for k8s coverage = $JSON"

NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")
RELEASE_NAME=$(jq -r '.release_name' < "$JSON_PARAMS")
GITALY_POD_NAME="${RELEASE_NAME}-gitaly-0"

CERT_MATCH_LINES=$(kubectl exec -i "${GITALY_POD_NAME}" -n "${NAMESPACE}" -- \
  bash -c "grep '$(sed -n '2,28p' < "${SCRIPTPATH}/public_key.crt")' /etc/ssl/certs/ca-certificates.crt | wc -l")

if (( "${CERT_MATCH_LINES}" % 27 != 0 )); then
  echo "Certificates not matched"
  exit 1
fi

