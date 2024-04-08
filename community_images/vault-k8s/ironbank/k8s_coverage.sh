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

git clone https://github.com/hashicorp-education/learn-vault-kubernetes-sidecar.git

pushd learn-vault-kubernetes-sidecar

kubectl exec \
  -n "${NAMESPACE}" \
  -it "${RELEASE_NAME}-0" \
  -- /bin/sh -c 'vault secrets enable -path=internal kv-v2'

kubectl exec \
  -n "${NAMESPACE}" \
  -it "${RELEASE_NAME}-0" \
  -- /bin/sh -c 'vault kv put internal/database/config username="db-readonly-username" password="db-secret-password"'

kubectl exec \
  -n "${NAMESPACE}" \
  -it "${RELEASE_NAME}-0" \
  -- /bin/sh -c 'vault kv get internal/database/config'

kubectl exec \
  -n "${NAMESPACE}" \
  -it "${RELEASE_NAME}-0" \
  -- /bin/sh -c 'vault auth enable kubernetes'

kubectl exec \
  -n "${NAMESPACE}" \
  -it "${RELEASE_NAME}-0" \
  -- /bin/sh -c 'vault write auth/kubernetes/config kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443"'

kubectl exec \
  -n "${NAMESPACE}" \
  -it "${RELEASE_NAME}-0" \
  -- /bin/sh -c 'vault policy write internal-app - <<EOF
path "internal/data/database/config" {
   capabilities = ["read"]
}
EOF
'

kubectl exec \
  -n "${NAMESPACE}" \
  -it "${RELEASE_NAME}-0" \
  -- /bin/sh -c "vault write auth/kubernetes/role/internal-app \
      bound_service_account_names=internal-app \
      bound_service_account_namespaces=${NAMESPACE} \
      policies=internal-app \
      ttl=24h"

kubectl create -n "${NAMESPACE}" sa internal-app

kubectl apply -n "${NAMESPACE}" --filename deployment-orgchart.yaml
sleep 10

## Inject Secrets

kubectl patch deployment -n "${NAMESPACE}" orgchart --patch "$(cat patch-inject-secrets.yaml)"
sleep 10


kubectl exec -n "${NAMESPACE}" \
      $(kubectl get pod -n "${NAMESPACE}" -l app=orgchart -o jsonpath="{.items[0].metadata.name}") \
      --container orgchart -- cat /vault/secrets/database-config.txt

## Apply a template to the injected secrets

kubectl patch deployment -n "${NAMESPACE}" orgchart --patch "$(cat patch-inject-secrets-as-template.yaml)"
sleep 10

kubectl exec -n "${NAMESPACE}" \
      $(kubectl get pod -n "${NAMESPACE}" -l app=orgchart -o jsonpath="{.items[0].metadata.name}") \
      -c orgchart -- cat /vault/secrets/database-config.txt


## Pod with annotations
kubectl apply -n "${NAMESPACE}" --filename pod-payroll.yaml
sleep 10

kubectl exec -n "${NAMESPACE}" \
      payroll \
      --container payroll -- cat /vault/secrets/database-config.txt

## Secrets are bound to the service account

kubectl apply -n "${NAMESPACE}" --filename deployment-website.yaml
sleep 10

kubectl patch -n "${NAMESPACE}" deployment website --patch "$(cat patch-website.yaml)"
sleep 10

kubectl exec -n "${NAMESPACE}" \
      $(kubectl get pod -n "${NAMESPACE}" -l app=website -o jsonpath="{.items[0].metadata.name}") \
      --container website -- cat /vault/secrets/database-config.txt


kubectl create namespace offsite

kubectl config set-context --current --namespace offsite

kubectl create -n offsite sa internal-app

kubectl apply -n offsite --filename deployment-issues.yaml
sleep 10

kubectl exec --namespace "${NAMESPACE}" -it "${RELEASE_NAME}-0" -- /bin/sh -c 'vault write auth/kubernetes/role/offsite-app \
   bound_service_account_names=internal-app \
   bound_service_account_namespaces=offsite \
   policies=internal-app \
   ttl=24h
'

kubectl patch -n offsite deployment issues --patch "$(cat patch-issues.yaml)"
sleep 10

kubectl exec -n offsite \
   $(kubectl get pod -n offsite -l app=issues -o jsonpath="{.items[0].metadata.name}") \
   --container issues -- cat /vault/secrets/database-config.txt


kubectl delete -n offsite --filename deployment-issues.yaml
kubectl delete -n "${NAMESPACE}" --filename deployment-website.yaml
kubectl delete -n "${NAMESPACE}" --filename pod-payroll.yaml
kubectl delete -n "${NAMESPACE}" --filename deployment-orgchart.yaml

kubectl delete namespace offsite

popd