#!/bin/bash

# Usage: Takes namespace as an argument and deletes the prometheus helm release in that namespace

# Check if first argument is empty
if [ -z "$1" ]
then
  echo "Error: Please provide a namespace as an argument to cleanup the prometheus helm release!"
  echo "Cleanup for prometheus Helm Release Failed!"
  exit 1
fi

NAMESPACE="$1"

echo "Printing Services in k8s namespace ${NAMESPACE} before cleaning up prometheus release ..."
kubectl -n "${NAMESPACE}" get svc

echo "Starting cleanup process for prometheus helm release in namespace ${NAMESPACE} ..."

helm uninstall prometheus --namespace "${NAMESPACE}"

echo "Cleanup script for prometheus helm release executed."