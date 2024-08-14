#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

CASS_CONTAINER_NAME="cass"

# sleep because cass server also sleeps for 30 while waiting for elasticsearch
sleep 30

# fetching the dynamically assigned port for cass using container name
CASS_PORT=$(docker port "$CASS_CONTAINER_NAME" 80 | head -n 1 | awk -F: '{print $2}')

if [ -z "$CASS_PORT" ]; then
  echo "Failed to retrieve the port for cass. Ensure the service is running."
  exit 1
fi

check_curl_success() {
  local url=$1
  local response=$(curl -o /dev/null -s -w "%{http_code}" "$url")
  
  if [ "$response" -eq 200 ]; then
    echo "Request to $url was successful."
    return 0
  else
    echo "Request to $url failed with status code $response."
    return 1
  fi
}

check_curl_success "localhost:${CASS_PORT}"

check_curl_success "localhost:${CASS_PORT}/#/frameworks"

check_curl_success "localhost:${CASS_PORT}/#/crosswalk"

check_curl_success "localhost:${CASS_PORT}/#/concepts"

check_curl_success "localhost:${CASS_PORT}/#/import"

check_curl_success "localhost:${CASS_PORT}/#/configuration"

check_curl_success "localhost:${CASS_PORT}/#/pluginManager"
