# Install rf
curl  https://frontrow.rapidfort.com/cli/ | bash
rflogin vg@vinodgupta.org ${RF_PASSWORD}

# Install helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

# Add bitnami repo
helm repo add bitnami https://charts.bitnami.com/bitnami

# Create namespace
kubectl create namespace ci-dev

# Add secret
kubectl --namespace ci-dev create secret generic rf-regcred --from-file=.dockerconfigjson=/home/ubuntu/.docker/config.json --type=kubernetes.io/dockerconfigjson

# remove file
rm -f get_helm.sh
