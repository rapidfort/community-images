#!/bin/bash

set -ex

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "JSON parameters = ${JSON}"

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

mkdir --parents --mode=777 "${SCRIPTPATH}"/logs/
