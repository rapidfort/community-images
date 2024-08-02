#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")

# extracting thanos image details from JSON params to use in prometheus helm chart (which deploys thanos as a sidecar process)
THANOS_IMAGE_REPO_PATH=$(jq -r '.image_tag_details."thanos-ib".repo_path' < "$JSON_PARAMS")
THANOS_IMAGE_TAG=$(jq -r '.image_tag_details."thanos-ib".tag' < "$JSON_PARAMS")

RELEASE_NAME="prometheus"
PROMETHEUS_CHART="oci://registry-1.docker.io/bitnamicharts/prometheus"
OVERRIDES_FILE="${SCRIPTPATH}/prometheus_chart_overrides.yml"

# Check if namespace exists
if kubectl get namespace "${NAMESPACE}"; then
  echo "Namespace ${NAMESPACE} already exists ..."
  echo "Skipping namespace creation ..."
else
  # Create namespace if it doesn't exist
  echo "Creating namespace ${NAMESPACE} ..."
  kubectl create namespace "${NAMESPACE}"
fi

# adding cleanup trap for prometheus helm release
# beyond this point, if THIS script exits WITH AN ERROR, the cleanup script will be executed
trap '${SCRIPTPATH}/cleanup_script_for_prometheus_helm_release.sh ${NAMESPACE}' ERR

# Deploying Prometheus Helm Chart
echo "Deploying Helm chart: $PROMETHEUS_CHART"
helm upgrade --install "${RELEASE_NAME}" "${PROMETHEUS_CHART}" -n "${NAMESPACE}" --set thanos.image.repository="${THANOS_IMAGE_REPO_PATH}" --set thanos.image.tag="${THANOS_IMAGE_TAG}" -f "${OVERRIDES_FILE}"

echo "Helm chart '$PROMETHEUS_CHART' deployed successfully in namespace '$NAMESPACE' with release name '$RELEASE_NAME'"
echo "Image used for thanos sidecar container is '${THANOS_IMAGE_REPO_PATH}':'${THANOS_IMAGE_TAG}'"

# Waiting for pods to come up
echo "Waiting for pods to be ready..."
SLEEP_INTERVAL=10
WAIT_TIME=300
end_time=$((SECONDS + WAIT_TIME))

while [ $SECONDS -lt $end_time ]; do
    all_ready=true
    for pod in $(kubectl get pods -n "${NAMESPACE}" -l "release=${RELEASE_NAME}" -o jsonpath='{.items[*].metadata.name}'); do
        pod_status=$(kubectl get pod "${pod}" -n "${NAMESPACE}" -o jsonpath='{.status.phase}')
        if [ "${pod_status}" != "Running" ]; then
            all_ready=false
            break
        fi
    done

    if [ "${all_ready}" = true ]; then
        echo "All pods are ready."
        break
    fi

    sleep "${SLEEP_INTERVAL}"
done

if [ "${all_ready}" != true ]; then
    echo "Error: Not all pods are ready after ${WAIT_TIME} seconds."
    exit 1
fi


# Using yq to put namespace and release name in both the overrides file for thanos chart (which will later be deployed by orchestrator) 
THANOS_CHART_RELEASE_NAME="rf-thanos-ib"
THANOS_CHART_OVERRIDES_FILE="${SCRIPTPATH}/thanos_chart_overrides.yml"
# namespace is same
yq -i ".query.stores[0] = \"dnssrv+_grpc._tcp.${THANOS_CHART_RELEASE_NAME}-storegateway.${NAMESPACE}.svc.cluster.local\"" "${THANOS_CHART_OVERRIDES_FILE}"
yq -i ".query.stores[1] = \"dnssrv+_grpc._tcp.${THANOS_CHART_RELEASE_NAME}-ruler.${NAMESPACE}.svc.cluster.local\"" "${THANOS_CHART_OVERRIDES_FILE}"
yq -i ".query.stores[2] = \"prometheus-thanos.${NAMESPACE}.svc.cluster.local:10901\"" "${THANOS_CHART_OVERRIDES_FILE}"
yq -i ".ruler.alertmanagers[0] = \"http://prometheus-alertmanager.${NAMESPACE}.svc.cluster.local:80\"" "${THANOS_CHART_OVERRIDES_FILE}"
yq -i ".ruler.config[0] = \"http://prometheus-server.${NAMESPACE}.svc.cluster.local:80\"" "${THANOS_CHART_OVERRIDES_FILE}"

THANOS_CHART_HARDEN_OVERRIDES_FILE="${SCRIPTPATH}/thanos_chart_harden_overrides.yml"
yq -i ".query.stores[0] = \"dnssrv+_grpc._tcp.${THANOS_CHART_RELEASE_NAME}-storegateway.${NAMESPACE}.svc.cluster.local\"" "${THANOS_CHART_HARDEN_OVERRIDES_FILE}"
yq -i ".query.stores[1] = \"dnssrv+_grpc._tcp.${THANOS_CHART_RELEASE_NAME}-ruler.${NAMESPACE}.svc.cluster.local\"" "${THANOS_CHART_HARDEN_OVERRIDES_FILE}"
yq -i ".query.stores[2] = \"prometheus-thanos.${NAMESPACE}.svc.cluster.local:10901\"" "${THANOS_CHART_HARDEN_OVERRIDES_FILE}"
yq -i ".ruler.alertmanagers[0] = \"http://prometheus-alertmanager.${NAMESPACE}.svc.cluster.local:80\"" "${THANOS_CHART_HARDEN_OVERRIDES_FILE}"
yq -i ".ruler.config[0] = \"http://prometheus-server.${NAMESPACE}.svc.cluster.local:80\"" "${THANOS_CHART_HARDEN_OVERRIDES_FILE}"