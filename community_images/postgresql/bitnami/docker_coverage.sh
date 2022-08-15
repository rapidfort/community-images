#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker coverage = $JSON"

NETWORK_NAME=$(jq -r '.network_name' < "$JSON_PARAMS")
PG_HOST=$(jq -r '.container_details.postgresql.ip_address' < "$JSON_PARAMS")
PG_IMAGE_REPO=$(jq -r '.image_tag_details.postgresql.repo_path' < "$JSON_PARAMS")
PG_IMAGE_TAG=$(jq -r '.image_tag_details.postgresql.tag' < "$JSON_PARAMS")

# run test on docker container
docker run --rm --network="${NETWORK_NAME}" \
    -i --env="PGPASSWORD=PgPwd" "${PG_IMAGE_REPO}:${PG_IMAGE_TAG}" \
    -- pgbench --host "${PG_HOST}" -U postgres -d postgres -p 5432 -i -s 50
