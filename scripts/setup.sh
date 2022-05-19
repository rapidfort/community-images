# this script keeps track of all things which need to be installed on github actions worker VM

# Install rf
curl  https://frontrow.rapidfort.com/cli/ | bash
rflogin vg@vinodgupta.org ${RF_PASSWORD}

# Install helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

# Add bitnami repo
helm repo add bitnami https://charts.bitnami.com/bitnami

# Add secret
kubectl --namespace ci-dev create secret generic rf-regcred --from-file=.dockerconfigjson=/home/ubuntu/.docker/config.json --type=kubernetes.io/dockerconfigjson

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
kubectl apply -f cert_manager.yml

# install some helpers
sudo apt-get install jq parallel docker-compose -y

# do docker login as well before completion