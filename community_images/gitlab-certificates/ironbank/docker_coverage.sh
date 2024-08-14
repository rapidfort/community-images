#!/bin/bash

set -x
set -e

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker coverage = $JSON"

CONTAINER_NAME=$(jq -r '.container_details."gitlab-certificates-ib".name' "${JSON_PARAMS}")

docker exec -i --user root "${CONTAINER_NAME}" \
  /scripts/entrypoint-ubi8.sh echo Done

docker exec -i --user root "${CONTAINER_NAME}" \
  /scripts/entrypoint.sh echo Done

docker exec -i --user root "${CONTAINER_NAME}" \
  /scripts/bundle-certificates

rm -rf \
  "${SCRIPTPATH}/private_key.pem" \
  "${SCRIPTPATH}/private_key2.pem" \
  "${SCRIPTPATH}/public_key.crt" \
  "${SCRIPTPATH}/public_key2.crt"

