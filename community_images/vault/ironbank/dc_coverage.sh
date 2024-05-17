#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")
CONTAINER_NAME=${PROJECT_NAME}-vault-1

docker exec "${CONTAINER_NAME}" vault version

UNSEAL_KEY=$(docker logs "${CONTAINER_NAME}" 2>&1 | grep "Unseal Key" | awk '{print $NF}')
ROOT_TOKEN=$(docker logs "${CONTAINER_NAME}" 2>&1 | grep "Root Token" | awk '{print $NF}')

echo "Unseal Key: $UNSEAL_KEY"
echo "Root Token: $ROOT_TOKEN"

docker exec "${CONTAINER_NAME}" vault operator unseal "$UNSEAL_KEY"

# docker exec "${CONTAINER_NAME}" vault operator init \
#   -key-shares=1 \
#   -key-threshold=1 \
#   -format=json > /vault/file/keys

# docker exec "${CONTAINER_NAME}" cat /tmp/keys.json

# UNSEAL_KEYS=$(docker exec "${CONTAINER_NAME}" sh -c '
#   grep "Unseal Key" /tmp/keys.json | awk -F": " "{print \$2}"
# ')

# echo "$UNSEAL_KEYS" | while read -r key; do
#   docker exec "${CONTAINER_NAME}" vault operator unseal "$key"
# done

# ROOT_TOKEN=$(docker exec "${CONTAINER_NAME}" sh -c '
#   grep "Initial Root Token" /tmp/keys.json | awk -F": " "{print \$2}"
# ')

docker exec "${CONTAINER_NAME}" vault login "$ROOT_TOKEN"

# docker exec "${CONTAINER_NAME}" vault secrets enable -path=secret kv-v2

docker exec "${CONTAINER_NAME}" vault path-help secret

docker exec "${CONTAINER_NAME}" vault kv put secret/webapp/config username="static-user" password="static-password"

docker exec "${CONTAINER_NAME}" vault kv get secret/webapp/config

docker exec "${CONTAINER_NAME}" vault auth enable kubernetes
