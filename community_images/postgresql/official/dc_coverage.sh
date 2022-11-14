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
PG_CONTAINER="${PROJECT_NAME}"-postgresql-1
# Get Port
#PG_PORT=$(docker inspect "${PG_CONTAINER}" | jq -r ".[].NetworkSettings.Ports.\"5432/tcp\"[0].HostPort")

# run pg tests
docker exec -i "${PG_CONTAINER}" bash -c "PGPASSWORD=${POSTGRESQL_PASSWORD} psql --host localhost -U postgres -d postgres -p 5432 -f /tmp/test.psql"

# run pg coverage
docker exec -i "${PG_CONTAINER}" bash -c "/tmp/postgres_coverage.sh"

# run pgbench
docker exec -i "${PG_CONTAINER}" pgbench --host localhost -U postgres -d postgres -p 5432 -i -s 50
