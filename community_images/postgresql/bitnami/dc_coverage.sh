#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

NETWORK_NAME=$(jq -r '.network_name' < "$JSON_PARAMS")
PG_IMAGE_REPO=$(jq -r '.image_tag_details.postgresql.repo_path' < "$JSON_PARAMS")
PG_IMAGE_TAG=$(jq -r '.release_name.postgresql.tag' < "$JSON_PARAMS")

# password
POSTGRESQL_PASSWORD=my_password

# run pg benchmark container
docker run --rm -i --network="${NETWORK_NAME}" \
    --env="PGPASSWORD=${POSTGRESQL_PASSWORD}" \
    "${PG_IMAGE_REPO}:${PG_IMAGE_TAG}" \
    -- pgbench --host postgresql-master -U postgres -d postgres -p 5432 -i -s 50
