#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

git clone https://github.com/helm/examples.git "${SCRIPTPATH}/examples"

yq -i '.version="0.1.2"' "${SCRIPTPATH}/examples/charts/hello-world/Chart.yaml"
