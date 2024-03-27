#!/bin/bash

# The password for Argo CD, passed as the first argument to the script
ARGOCD_PASSWORD="$1"

# Argo CD operations
set -e
set -x

# Function to log in to Argo CD
function argocd_login() {
    echo "Logging into Argo CD..."
    argocd login localhost:8080 --username admin --password "${ARGOCD_PASSWORD}" --insecure
}

# Function to create an Argo CD application
function argocd_create_app() {
    local app_name="$1"
    local repo_url="$2"
    local path="$3"
    local dest_server="$4"
    local dest_namespace="$5"

    echo "Creating Argo CD application '${app_name}'..."
    argocd app create "${app_name}" \
        --repo "${repo_url}" \
        --path "${path}" \
        --dest-server "${dest_server}" \
        --dest-namespace "${dest_namespace}"
}

# Function to list Argo CD applications
function argocd_list_apps() {
    echo "Listing Argo CD applications..."
    argocd app list
}

# Function to sync an Argo CD application
function argocd_sync_app() {
    local app_name="$1"

    echo "Syncing Argo CD application '${app_name}'..."
    argocd app sync "${app_name}"
}

# Function to delete an Argo CD application
function argocd_delete_app() {
    local app_name="$1"

    echo "Deleting Argo CD application '${app_name}'..."
    argocd app delete "${app_name}" --cascade -y
}

# Main execution flow
argocd_login

# Replace these placeholders with your actual application details
APP_NAME="example-app"
REPO_URL="https://github.com/argoproj/argocd-example-apps.git"
APP_PATH="guestbook"
DEST_SERVER="https://kubernetes.default.svc" # Kubernetes API server URL
DEST_NAMESPACE="default"

argocd_create_app "${APP_NAME}" "${REPO_URL}" "${APP_PATH}" "${DEST_SERVER}" "${DEST_NAMESPACE}"
argocd_list_apps
argocd_sync_app "${APP_NAME}"
argocd_delete_app "${APP_NAME}"

echo "Argo CD coverage operations completed successfully."

