#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

PAUSE_CONTAINER=$(jq -r '.container_details."pause-ib".name' < "$JSON_PARAMS")
NGINX_CONTAINER="nginx-ironbank"

docker run -d --name "$NGINX_CONTAINER" --net=container:"$PAUSE_CONTAINER" --pid=container:"$PAUSE_CONTAINER" rapidfort/nginx-ib:latest


#checking if both pause and nginx share the same namespace or not 

function get_container_interfaces() {

  if ! CONTAINER_PID=$(docker inspect --format '{{ .State.Pid }}' "$1")
  then
    echo "Error: Failed to inspect container '$1'"
    exit 1
  fi
  sudo nsenter -n -t "$CONTAINER_PID" ip addr show scope global
}

PAUSE_NETWORK_INTERFACE=$(get_container_interfaces "$PAUSE_CONTAINER") #Getting network namespace for pause
NGINX_NETWORK_INTERFACE=$(get_container_interfaces "$NGINX_CONTAINER") #Getting network namespace for nginx-ironbank
if [[ "$PAUSE_NETWORK_INTERFACE" == "$NGINX_NETWORK_INTERFACE" ]]; then
  echo "Both containers ($PAUSE_CONTAINER and $NGINX_CONTAINER) share the same network namespace."
else
  echo "The containers have different network namespaces:"
  echo "  - $PAUSE_CONTAINER:"
  echo "$PAUSE_NETWORK_INTERFACE"
  echo "  - $NGINX_CONTAINER:"
  echo "$NGINX_NETWORK_INTERFACE"
  exit 1
fi

docker stop "$NGINX_CONTAINER"
docker remove "$NGINX_CONTAINER"

