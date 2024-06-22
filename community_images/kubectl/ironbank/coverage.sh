#!/bin/bash

kubectl version

kubectl get pods

kubectl create namespace custom-namespace

kubectl create deployment nginx --image=nginx --namespace=custom-namespace

kubectl get pods --namespace=custom-namespace

kubectl run busybox --image=busybox --namespace=custom-namespace -- sleep 3600

kubectl create configmap example-config --from-literal=key1=value1 --namespace=custom-namespace

kubectl create configmap example-config --from-literal=key1=value1 --namespace=custom-namespace

kubectl create clusterrole example-clusterrole --verb=get,list,watch --resource=pods

kubectl create serviceaccount example-sa --namespace=custom-namespace

kubectl create clusterrolebinding example-clusterrolebinding --clusterrole=example-clusterrole --serviceaccount=custom-namespace:example-sa

kubectl create cronjob example-cronjob --schedule="*/1 * * * *" --namespace=custom-namespace --image=busybox -- /bin/sh -c "date; echo Hello from Kubernetes cluster"

kubectl delete cronjob example-cronjob --namespace=custom-namespace

kubectl delete configmap example-config --namespace=custom-namespace

kubectl delete clusterrolebinding example-clusterrolebinding

kubectl delete clusterrole example-clusterrole

kubectl delete namespace custom-namespace

kubectl delete pod busybox --namespace=custom-namespace
kubectl delete deployment nginx --namespace=custom-namespace

kubectl delete namespace custom-namespace

