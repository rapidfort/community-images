#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")

# password
POSTGRESQL_PASSWORD=my_password

# pg container
PG_CONTAINER="${PROJECT_NAME}"-postgresql-master-1

# password
POSTGRESQL_PASSWORD=my_password

# Get Port
#PG_PORT=$(docker inspect "${PG_CONTAINER}" | jq -r ".[].NetworkSettings.Ports.\"5432/tcp\"[0].HostPort")

# run pgbench test
docker exec -i "${PG_CONTAINER}" pgbench --host localhost -U postgres -d postgres -p 5432 -i -s 50