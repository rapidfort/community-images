#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")
CONTAINER_NAME="${PROJECT_NAME}"-etcd1-1

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# copy etcd_test.sh into container
docker cp "${SCRIPTPATH}"/etcd_test.sh "${CONTAINER_NAME}":/tmp/etcd_test.sh

# run etcd_test on cluster
docker exec "${CONTAINER_NAME}" /bin/bash -c "/tmp/etcd_test.sh etcdrootpwd"
