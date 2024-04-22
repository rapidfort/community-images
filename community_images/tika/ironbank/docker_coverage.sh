#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker coverage = $JSON"

# shellcheck disable=SC1091
SCRIPTPATH=$(jq -r '.image_script_dir' < "$JSON_PARAMS")
CONTAINER_NAME=$(jq -r '.container_details."tika-ib".name' < "$JSON_PARAMS")

docker exec -i "${CONTAINER_NAME}" /bin/bash -c "./opt/tika/docker_coverage_assets/coverage.sh"