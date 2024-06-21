#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")
CONTAINER_NAME=${PROJECT_NAME}-k8ssidecar-1
echo "$CONTAINER_NAME"
# NAMESPACE=$(jq -r '.namespace_name' <<< "$JSON")
REPO_PATH=$(jq -r '.image_tag_details."k8s-sidecar-ib".repo_path' <<< "$JSON")
TAG=$(jq -r '.image_tag_details."k8s-sidecar-ib".tag' <<< "$JSON")

# Define the YAML content with inline variables for pod sidecar pod creation
YAML_CONTENT=$(cat <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-deployment
  labels:
    app: sample
spec:
  replicas: 1
  selector:
    matchLabels:
      app: sample
  template:
    metadata:
        labels:
          app: sample
    spec:
      serviceAccountName: sample-acc
      containers:
      - name: bash
        image: bash:5.2.15
        volumeMounts:
        - name: shared-volume
          mountPath: /tmp/
        command: ["watch"]
        args: ["ls", "/tmp/"]
      - name: sidecar
        image: ${REPO_PATH}:${TAG}   # Replace the image with the variable
        volumeMounts:
        - name: shared-volume
          mountPath: /tmp/
        env:
        - name: LABEL
          value: "findme"
        - name: FOLDER
          value: /tmp/
        - name: RESOURCE
          value: both
        - name: SCRIPT
          value: "/opt/script.sh"
        - name: REQ_USERNAME
          value: "user1"
        - name: REQ_PASSWORD
          value: "abcdefghijklmnopqrstuvwxyz"
        - name: REQ_BASIC_AUTH_ENCODING
            # the python server we're using for the tests expects ascii encoding of basic auth credentials, hence we can't use non-ascii characters in the password or username
          value: "ascii"
        - name: LOG_LEVEL
          value: "DEBUG"
        securityContext:          # Add the securityContext section here
          capabilities:           # Specify the capabilities for the container
            add:
            - SYS_PTRACE
      volumes:
      - name: shared-volume
        emptyDir: {}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: sample-configmap
  labels:
    findme: "yea"
data:
  hello.world: |-
     Hello World!
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: sample-configmap-from-url
  labels:
        findme: "yea"
data:
  # fetch https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/grafana/dashboards/nginx.json with the grafana sidecar
  # .url will be stripped and the file will be called nginx-ingress.json
  nginx-ingress.json.url: https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/grafana/dashboards/nginx.json
---
apiVersion: v1
kind: Secret
metadata:
  name: sample-secret
  labels:
    findme: "yea"
type: Opaque
data:
  # base64 encoded: my super cool \n multiline \ secret
  secret.world: bXkgc3VwZXIgY29vbAptdWx0aWxpbmUKc2VjcmV0
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: sample-role
rules:
- apiGroups: [""]
  resources: ["configmaps", "secrets"]
  verbs: ["get", "watch", "list"]
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: sample-acc
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: sample-rolebind
roleRef:
  kind: ClusterRole
  name: sample-role
  apiGroup: rbac.authorization.k8s.io
subjects:
- kind: ServiceAccount
  name: sample-acc
  namespace: default
EOF
)

# Apply configuration with substituted variables
echo "$YAML_CONTENT" | kubectl apply -f -
sleep 10
# getting pod details
kubectl get pods -l app=sample
kubectl describe pods -l app=sample
POD_NAME=$(kubectl get pods -l app=sample -o jsonpath='{.items[0].metadata.name}')
# Execute the Python script "sidecar.py" for changes or list resources (such as ConfigMaps or Secrets)
kubectl exec -i "$POD_NAME" -c sidecar -- python sidecar.py &
# Wait for 60 seconds
sleep 60
# Kill the process
kill %1
# Delete the resources created in deployment
kubectl delete deployment sample-deployment
kubectl delete configmap sample-configmap
kubectl delete configmap sample-configmap-from-url
kubectl delete secret sample-secret
kubectl delete serviceaccount sample-acc
kubectl delete clusterrolebinding sample-rolebind


