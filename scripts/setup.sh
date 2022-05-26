#!/bin/bash

FUNCTIONAL_TEST_SETUP=no
while [[ $# -gt 0 ]]; do
  case $1 in
    -f|--functional)
      FUNCTIONAL_TEST_SETUP="$2"
      shift # past argument
      shift # past value
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

# this script keeps track of all things which need to be installed on github actions worker VM
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit ; pwd -P )"

if [[ "${FUNCTIONAL_TEST_SETUP}" = "no" ]]; then
  # Install rf
  curl  https://frontrow.rapidfort.com/cli/ | bash
  rflogin "${RF_USERNAME}" "${RF_PASSWORD}"

  # do docker login
  docker login -u "${DOCKERHUB_USERNAME}" -p "${DOCKERHUB_PASSWORD}"
fi

# Install helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

# Add bitnami repo
helm repo add bitnami https://charts.bitnami.com/bitnami

# remove file
rm -f get_helm.sh

# add cert manager
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.7.1 \
  --set installCRDs=true

# create CA issuer
kubectl apply -f "${SCRIPTPATH}"/cert_manager.yml

# install some helpers
sudo apt-get install jq parallel docker-compose -y

# add ingress
minikube addons enable ingress