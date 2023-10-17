#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker coverage = $JSON"

NETWORK_NAME=$(jq -r '.network_name' < "$JSON_PARAMS")
PG_HOST=$(jq -r '.container_details.postgresql.ip_address' < "$JSON_PARAMS")

# run test on docker container
docker run --rm --network="${NETWORK_NAME}" \
    -i --env="PGPASSWORD=PgPwd" rapidfort/postgresql:latest \
    -- pgbench --host "${PG_HOST}" -U postgres -d postgres -p 5432 -i -s 25
