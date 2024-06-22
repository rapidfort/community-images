#!/bin/bash
cat /.kube/config

kubectl version

kubectl get pods

kubectl auth can-i create pods --all-namespaces

kubectl create namespace custom-namespace

kubectl create deployment nginx-deployment --image=nginx --namespace=custom-namespace

kubectl get pods --namespace=custom-namespace

kubectl run busybox --image=busybox --namespace=custom-namespace -- sleep 3600

kubectl create configmap example-config --from-literal=key1=value1 --namespace=custom-namespace

kubectl create clusterrole example-clusterrole --verb=get,list,watch --resource=pods

kubectl create serviceaccount example-sa --namespace=custom-namespace

kubectl create clusterrolebinding example-clusterrolebinding --clusterrole=example-clusterrole --serviceaccount=custom-namespace:example-sa

kubectl create cronjob example-cronjob --schedule="*/1 * * * *" --namespace=custom-namespace --image=busybox -- /bin/sh -c "date; echo Hello from Kubernetes cluster"

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

kubectl create job example-job --image=busybox --namespace=custom-namespace -- /bin/sh -c "echo Hello from the Kubernetes job; sleep 30"

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

kubectl create role example-role --verb=get,list,watch --resource=pods --namespace=custom-namespace

kubectl create rolebinding example-rolebinding --role=example-role --serviceaccount=custom-namespace:example-sa --namespace=custom-namespace

cat <<EOF | kubectl apply -f -
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high-priority
value: 1000
globalDefault: false
description: "This priority class is used for high priority pods."
EOF

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

kubectl create secret docker-registry example-docker-secret --docker-server=my-registry.io --docker-username=my-username --docker-password=my-password --docker-email=my-email@example.com --namespace=custom-namespace

kubectl create secret generic example-generic-secret --from-literal=key1=value1 --namespace=custom-namespace

kubectl expose deployment nginx-deployment --port=80 --target-port=80 --name=nginx-service --namespace=custom-namespace

kubectl create service externalname example-externalname --external-name=example.com --namespace=custom-namespace

kubectl expose deployment nginx-deployment --type=LoadBalancer --name=nginx-loadbalancer --port=80 --target-port=80 --namespace=custom-namespace

kubectl expose deployment nginx-deployment --type=NodePort --name=nginx-nodeport --port=80 --target-port=80 --namespace=custom-namespace

kubectl describe namespace custom-namespace

kubectl delete secret example-docker-secret --namespace=custom-namespace

kubectl delete secret example-generic-secret --namespace=custom-namespace

kubectl delete secret example-tls-secret --namespace=custom-namespace

kubectl delete service nginx-service --namespace=custom-namespace

kubectl delete service example-externalname --namespace=custom-namespace

kubectl delete service nginx-loadbalancer --namespace=custom-namespace

kubectl delete service nginx-nodeport --namespace=custom-namespace

kubectl delete resourcequota example-quota --namespace=custom-namespace

kubectl delete priorityclass high-priority

kubectl delete rolebinding example-rolebinding --namespace=custom-namespace

kubectl delete role example-role --namespace=custom-namespace

kubectl delete pdb example-pdb --namespace=custom-namespace

kubectl delete job example-job --namespace=custom-namespace

kubectl delete ingress example-ingress --namespace=custom-namespace

kubectl delete cronjob example-cronjob --namespace=custom-namespace

kubectl delete configmap example-config --namespace=custom-namespace

kubectl delete clusterrolebinding example-clusterrolebinding

kubectl delete clusterrole example-clusterrole

kubectl delete pod busybox --namespace=custom-namespace

kubectl delete deployment nginx-deployment --namespace=custom-namespace

kubectl delete namespace custom-namespace

