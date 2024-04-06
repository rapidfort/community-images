#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

CONTAINER1_NAME=$(jq -r '.container_details."pause-ib".name' < "$JSON_PARAMS")
CONTAINER2_NAME="nginx-ironbank"
docker run -d --name "$CONTAINER2_NAME" --net=container:"$CONTAINER1_NAME" --pid=container:"$CONTAINER1_NAME" registry1.dso.mil/ironbank/opensource/nginx/nginx

#checking if both pause and nginx share the same namespace or not 

function get_container_interfaces() {
  container_pid=$(docker inspect --format '{{ .State.Pid }}' "$1")
  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to inspect container '$1'"
    exit 1
  fi
  sudo nsenter -n -t "$container_pid" ip addr show scope global
}

CONTAINER1_INTERFACE=$(get_container_interfaces "$CONTAINER1_NAME") #Getting network namespace for pause
CONTAINER2_INTERFACE=$(get_container_interfaces "$CONTAINER2_NAME") #Getting network namespace for nginx-ironbank
if [[ "$CONTAINER1_INTERFACE" == "$CONTAINER2_INTERFACE" ]]; then
  echo "Both containers ($CONTAINER1_NAME and $CONTAINER2_NAME) share the same network namespace."
else
  echo "The containers have different network namespaces:"
  echo "  - $CONTAINER1_NAME:"
  echo "$CONTAINER1_INTERFACE"
  echo "  - $CONTAINER2_NAME:"
  echo "$CONTAINER2_INTERFACE"
  exit 1
fi

docker stop "$CONTAINER2_NAME"
docker remove "$CONTAINER2_NAME"

