#!/bin/bash

set -x
set -e

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for k8s coverage = $JSON"

NAMESPACE=$(jq -r '.namespace_name' "${JSON_PARAMS}")

pushd "${SCRIPTPATH}"
  # Create .crt files to add to certificates container
  openssl req -x509 -newkey rsa:4096 -keyout private_key.pem -out public_key.crt -days 365 -nodes -subj '/CN=issuer'
  openssl req -x509 -newkey rsa:4096 -keyout private_key2.pem -out public_key2.crt -days 365 -nodes -subj '/CN=issuer'

  kubectl create namespace "${NAMESPACE}"
  kubectl create configmap cm-custom-ca --from-file=unique_name_1.crt=public_key.crt --namespace "${NAMESPACE}"
  kubectl create secret generic secret-custom-ca --from-file=unique_name_2.crt=public_key2.crt --namespace "${NAMESPACE}"
popd

