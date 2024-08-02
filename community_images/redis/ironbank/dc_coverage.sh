#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")

CONTAINER_NAME="${NAMESPACE}"-redis-primary-1

IMAGE_KEY=$(jq -r '.image_tag_details | keys[0]' < "$JSON_PARAMS")
SHELL="bash"
if [[ $IMAGE_KEY == redis6-alpine-ib ]]; then
  SHELL="sh"
fi

# run redis tests
docker exec -i "${CONTAINER_NAME}" "${SHELL}" -c "cat /tmp/test.redis | redis-cli"

# run redis coverage
docker exec -i "${CONTAINER_NAME}" "${SHELL}" < "${SCRIPTPATH}/../../common/tests/redis_coverage.sh"

