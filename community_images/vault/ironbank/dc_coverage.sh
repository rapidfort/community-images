#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")
CONTAINER_NAME=${PROJECT_NAME}-vault-1
# checking version
docker exec "${CONTAINER_NAME}" vault version
# extracting unseal key from container logs(dev mode)
UNSEAL_KEY=$(docker logs "${CONTAINER_NAME}" 2>&1 | grep "Unseal Key" | awk '{print $NF}')
#extracting root token from container logs
ROOT_TOKEN=$(docker logs "${CONTAINER_NAME}" 2>&1 | grep "Root Token" | awk '{print $NF}')
echo "Unseal Key: $UNSEAL_KEY"
echo "Root Token: $ROOT_TOKEN"
# using unseal key to operator
docker exec "${CONTAINER_NAME}" vault operator unseal "$UNSEAL_KEY"
# logon using root token
docker exec "${CONTAINER_NAME}" vault login "$ROOT_TOKEN"
# Display help information for the "secret" path in Vault.
docker exec "${CONTAINER_NAME}" vault path-help secret
# Store key-value pairs for web application configuration in the "secret/webapp/config" path.
docker exec "${CONTAINER_NAME}" vault kv put secret/webapp/config username="static-user" password="static-password"
# Retrieve key-value pairs stored for web application configuration in the "secret/webapp/config" path.
docker exec "${CONTAINER_NAME}" vault kv get secret/webapp/config
# Enable Kubernetes authentication method in Vault.
docker exec "${CONTAINER_NAME}" vault auth enable kubernetes
# Write policy to Vault
docker exec "${CONTAINER_NAME}" vault policy write webapp /tmp/policy.hcl
# Configure Kubernetes role in Vault
docker exec "${CONTAINER_NAME}" vault write auth/kubernetes/role/webapp \
    bound_service_account_names=vault \
    bound_service_account_namespaces=default \
    policies=webapp \
    ttl=24h