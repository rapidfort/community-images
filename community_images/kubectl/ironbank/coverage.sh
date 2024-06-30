#!/bin/bash

# Display the version of kubectl and the server it is connected to
kubectl version

# List all pods in all namespaces
kubectl get pods

# Check if the current user can create pods in all namespaces
kubectl auth can-i create pods --all-namespaces

# Create a new namespace named 'custom-namespace'
kubectl create namespace custom-namespace

# Create a deployment named 'nginx-deployment' using the nginx image in 'custom-namespace'
kubectl create deployment nginx-deployment --image=nginx --namespace=custom-namespace

# List all pods in the 'custom-namespace'
kubectl get pods --namespace=custom-namespace

# Run a pod named 'busybox' using the busybox image and sleep for 3600 seconds in 'custom-namespace'
kubectl run busybox --image=busybox --namespace=custom-namespace -- sleep 3600

# Create a ConfigMap named 'example-config' with a key-value pair in 'custom-namespace'
kubectl create configmap example-config --from-literal=key1=value1 --namespace=custom-namespace

# Create a ClusterRole named 'example-clusterrole' with permissions to get, list, and watch pods
kubectl create clusterrole example-clusterrole --verb=get,list,watch --resource=pods

# Create a ServiceAccount named 'example-sa' in 'custom-namespace'
kubectl create serviceaccount example-sa --namespace=custom-namespace

# Bind the 'example-clusterrole' to the 'example-sa' ServiceAccount in 'custom-namespace'
kubectl create clusterrolebinding example-clusterrolebinding --clusterrole=example-clusterrole --serviceaccount=custom-namespace:example-sa

# Create a CronJob named 'example-cronjob' that runs every minute in 'custom-namespace'
kubectl create cronjob example-cronjob --schedule="*/1 * * * *" --namespace=custom-namespace --image=busybox -- /bin/sh -c "date; echo Hello from Kubernetes cluster"

# Create an Ingress resource to expose the nginx deployment under the host 'example.com' in 'custom-namespace'
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
  namespace: custom-namespace
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx-deployment
            port:
              number: 80
EOF

# Create a Job named 'example-job' that runs a command and sleeps for 30 seconds in 'custom-namespace'
kubectl create job example-job --image=busybox --namespace=custom-namespace -- /bin/sh -c "echo Hello from the Kubernetes job; sleep 30"

# Create a Pod Disruption Budget to ensure at least one pod with the label 'app=nginx' is available in 'custom-namespace'
cat <<EOF | kubectl apply -f -
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: example-pdb
  namespace: custom-namespace
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: nginx
EOF

# Create a Role named 'example-role' with permissions to get, list, and watch pods in 'custom-namespace'
kubectl create role example-role --verb=get,list,watch --resource=pods --namespace=custom-namespace

# Bind the 'example-role' to the 'example-sa' ServiceAccount in 'custom-namespace'
kubectl create rolebinding example-rolebinding --role=example-role --serviceaccount=custom-namespace:example-sa --namespace=custom-namespace

# Create a PriorityClass named 'high-priority' with a value of 1000
cat <<EOF | kubectl apply -f -
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high-priority
value: 1000
globalDefault: false
description: "This priority class is used for high priority pods."
EOF

# Create a ResourceQuota named 'example-quota' in 'custom-namespace' with specified resource limits
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: example-quota
  namespace: custom-namespace
spec:
  hard:
    pods: "10"
    requests.cpu: "4"
    requests.memory: 8Gi
    limits.cpu: "10"
    limits.memory: 16Gi
EOF

# Create a Docker registry secret named 'example-docker-secret' in 'custom-namespace'
kubectl create secret docker-registry example-docker-secret --docker-server=my-registry.io --docker-username=my-username --docker-password=my-password --docker-email=my-email@example.com --namespace=custom-namespace

# Create a generic secret named 'example-generic-secret' with a key-value pair in 'custom-namespace'
kubectl create secret generic example-generic-secret --from-literal=key1=value1 --namespace=custom-namespace

# Expose the 'nginx-deployment' as a service named 'nginx-service' on port 80 in 'custom-namespace'
kubectl expose deployment nginx-deployment --port=80 --target-port=80 --name=nginx-service --namespace=custom-namespace

# Create an ExternalName service named 'example-externalname' pointing to 'example.com' in 'custom-namespace'
kubectl create service externalname example-externalname --external-name=example.com --namespace=custom-namespace

# Expose the 'nginx-deployment' as a LoadBalancer service named 'nginx-loadbalancer' on port 80 in 'custom-namespace'
kubectl expose deployment nginx-deployment --type=LoadBalancer --name=nginx-loadbalancer --port=80 --target-port=80 --namespace=custom-namespace

# Expose the 'nginx-deployment' as a NodePort service named 'nginx-nodeport' on port 80 in 'custom-namespace'
kubectl expose deployment nginx-deployment --type=NodePort --name=nginx-nodeport --port=80 --target-port=80 --namespace=custom-namespace

# Describe the 'custom-namespace' to view its details
kubectl describe namespace custom-namespace

# Delete the 'example-docker-secret' in 'custom-namespace'
kubectl delete secret example-docker-secret --namespace=custom-namespace

# Delete the 'example-generic-secret' in 'custom-namespace'
kubectl delete secret example-generic-secret --namespace=custom-namespace

# Delete the 'example-tls-secret' in 'custom-namespace'
kubectl delete secret example-tls-secret --namespace=custom-namespace

# Delete the 'nginx-service' service in 'custom-namespace'
kubectl delete service nginx-service --namespace=custom-namespace

# Delete the 'example-externalname' service in 'custom-namespace'
kubectl delete service example-externalname --namespace=custom-namespace

# Delete the 'nginx-loadbalancer' service in 'custom-namespace'
kubectl delete service nginx-loadbalancer --namespace=custom-namespace

# Delete the 'nginx-nodeport' service in 'custom-namespace'
kubectl delete service nginx-nodeport --namespace=custom-namespace

# Delete the 'example-quota' ResourceQuota in 'custom-namespace'
kubectl delete resourcequota example-quota --namespace=custom-namespace

# Delete the 'high-priority' PriorityClass
kubectl delete priorityclass high-priority

# Delete the 'example-rolebinding' RoleBinding in 'custom-namespace'
kubectl delete rolebinding example-rolebinding --namespace=custom-namespace

# Delete the 'example-role' Role in 'custom-namespace'
kubectl delete role example-role --namespace=custom-namespace

# Delete the 'example-pdb' Pod Disruption Budget in 'custom-namespace'
kubectl delete pdb example-pdb --namespace=custom-namespace

# Delete the 'example-job' Job in 'custom-namespace'
kubectl delete job example-job --namespace=custom-namespace

# Delete the 'example-ingress' Ingress in 'custom-namespace'
kubectl delete ingress example-ingress --namespace=custom-namespace

# Delete the 'example-cronjob' CronJob in 'custom-namespace'
kubectl delete cronjob example-cronjob --namespace=custom-namespace

# Delete the 'example-config' ConfigMap in 'custom-namespace'
kubectl delete configmap example-config --namespace=custom-namespace

# Delete the 'example-clusterrolebinding' ClusterRoleBinding
kubectl delete clusterrolebinding example-clusterrolebinding

# Delete the 'example-clusterrole' ClusterRole
kubectl delete clusterrole example-clusterrole

# Delete the 'busybox' pod in 'custom-namespace'
kubectl delete pod busybox --namespace=custom-namespace

# Delete the 'nginx-deployment' deployment in 'custom-namespace'
kubectl delete deployment nginx-deployment --namespace=custom-namespace

# Delete the 'custom-namespace' namespace
kubectl delete namespace custom-namespace
