#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

rm -rf "${SCRIPTPATH}/config" "${SCRIPTPATH}/logs" "${SCRIPTPATH}/data" "${SCRIPTPATH}"/id_*
mkdir "${SCRIPTPATH}/config" "${SCRIPTPATH}/logs" "${SCRIPTPATH}/data"

ssh-keygen -f "${SCRIPTPATH}/id_rsa" -N ""

