#!/bin/bash

set -x
set -e

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/mongo_helpers.sh

JSON_PARAMS="$1"
NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")
MONGODB_ROOT_PASSWORD=password123

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

# get docker host ip
MONGODB_HOST=$(docker inspect "${NAMESPACE}" | jq -r ".[].NetworkSettings.Networks[\"${NAMESPACE}\"].IPAddress")

# run tests
run_mongodb_test "$MONGODB_HOST" "$MONGODB_ROOT_PASSWORD" "${NAMESPACE}"