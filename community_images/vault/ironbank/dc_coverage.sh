#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")
CONTAINER_NAME=${PROJECT_NAME}-vault-1

docker exec "${CONTAINER_NAME}" vault version

docker exec "${CONTAINER_NAME}" vault operator init \
  -key-shares=1 \
  -key-threshold=1 \
  -format=json > /tmp/keys.json

docker exec "${CONTAINER_NAME}" cat /tmp/keys.json

UNSEAL_KEYS=$(docker exec "${CONTAINER_NAME}" sh -c '
  grep "Unseal Key" /tmp/keys.json | awk -F": " "{print \$2}"
')

echo "$UNSEAL_KEYS" | while read -r key; do
  docker exec "${CONTAINER_NAME}" vault operator unseal "$key"
done

ROOT_TOKEN=$(docker exec "${CONTAINER_NAME}" sh -c '
  grep "Initial Root Token" /tmp/keys.json | awk -F": " "{print \$2}"
')

docker exec "${CONTAINER_NAME}" vault login "$ROOT_TOKEN"

docker exec "${CONTAINER_NAME}" vault secrets enable -path=secret kv-v2

docker exec "${CONTAINER_NAME}" vault path-help secret

docker exec "${CONTAINER_NAME}" vault kv put secret/webapp/config username="static-user" password="static-password"

docker exec "${CONTAINER_NAME}" vault kv get secret/webapp/config

docker exec "${CONTAINER_NAME}" vault auth enable kubernetes
