#!/bin/bash

set -e
set -x

EPH_SETUP=no
while [[ $# -gt 0 ]]; do
  case $1 in
    -e|--eph)
      EPH_SETUP="$2"
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

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../community_images/common/scripts/bash_helper.sh

RF_PLATFORM_HOST=${RF_PLATFORM_HOST:-frontrow.rapidfort.io}

if [[ "${EPH_SETUP}" = "no" ]]; then
  # Install rf
  curl  https://"$RF_PLATFORM_HOST"/cli/ | bash
  rflogin

  # do docker login
  docker login -u "${DOCKERHUB_USERNAME}" -p "${DOCKERHUB_PASSWORD}"
else
  curl -k https://127.0.0.1/cli/ | bash
  rflogin
fi

# Install helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

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
sudo apt-get install jq parallel expect -y

# install docker-compose latest
DC_VERSION="$(with_backoff curl --silent https://api.github.com/repos/docker/compose/releases/latest | jq -r .tag_name)"
DC_DESTINATION=/usr/local/bin/docker-compose
echo "Downloding  https://github.com/docker/compose/releases/download/${DC_VERSION}/docker-compose-$(uname -s)-$(uname -m)"
with_backoff sudo curl -L https://github.com/docker/compose/releases/download/"${DC_VERSION}"/docker-compose-"$(uname -s)"-"$(uname -m)" -o "$DC_DESTINATION"
sudo chmod 755 $DC_DESTINATION

# upgrade bash, curl, openssl
sudo apt-get install --only-upgrade bash openssl curl -y
bash --version

# add ingress
minikube addons enable ingress

# add common python modules
pip install --upgrade pip
pip install backoff python-dateutil
