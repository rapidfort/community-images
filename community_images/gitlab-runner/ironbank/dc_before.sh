#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# Cleanup volumes(mounted directories) from previous run
rm -rf "${SCRIPTPATH}/config" "${SCRIPTPATH}/logs" "${SCRIPTPATH}/data" "${SCRIPTPATH}"/id_*
# Create directories to mount
mkdir "${SCRIPTPATH}/config" "${SCRIPTPATH}/logs" "${SCRIPTPATH}/data"

# Generate key pair for runner to ssh into another container(for covering ssh executor)
ssh-keygen -f "${SCRIPTPATH}/id_rsa" -N ""

