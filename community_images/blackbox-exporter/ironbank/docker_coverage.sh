#!/bin/bash

set -x
set -e

# JSON_PARAMS="$1"

# JSON=$(cat "$JSON_PARAMS")

# echo "Json params for docker coverage = $JSON"

# # NETWORK_NAME=$(jq -r '.network_name' < "$JSON_PARAMS")
# # ENVOY_HOST=$(jq -r '.container_details.envoy.ip_address' < "$JSON_PARAMS")


# CONTAINER_NAME=$(jq -r '.container_details."blackbox_exporter".name' < "$JSON_PARAMS")
CONTAINER_NAME="blackbox_exporter"

if [ -z "$CONTAINER_NAME" ]; then
  echo "Failed to fetch the container name for blackbox-exporter."
  exit 1
fi

# fetching the dynamically assigned port for blackbox-exporter using container name
BLACKBOX_EXPORTER_PORT=$(docker port "$CONTAINER_NAME" 9115 | head -n 1 | awk -F: '{print $2}')

if [ -z "$BLACKBOX_EXPORTER_PORT" ]; then
  echo "Failed to retrieve the port for blackbox-exporter. Ensure the service is running."
  exit 1
fi

# Base URL of the blackbox_exporter
BASE_URL="http://localhost:${BLACKBOX_EXPORTER_PORT}"

# Targets for different probes
HTTP_TARGET="http://example.com"
TCP_TARGET="example.com:80"
ICMP_TARGET="8.8.8.8"
DNS_TARGET="8.8.8.8"

# Scrape metrics for each module
echo "Scraping HTTP probe..."
curl "${BASE_URL}/probe?target=${HTTP_TARGET}&module=http_2xx&debug=true"

echo "Scraping TCP probe..."
curl "${BASE_URL}/probe?target=${TCP_TARGET}&module=tcp_connect&debug=true"

echo "Scraping ICMP probe..."
curl "${BASE_URL}/probe?target=${ICMP_TARGET}&module=icmp&debug=true"

echo "Scraping DNS probe..."
curl "${BASE_URL}/probe?target=${DNS_TARGET}&module=dns&debug=true"
