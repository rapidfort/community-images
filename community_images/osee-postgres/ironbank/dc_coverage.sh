#!/bin/bash

set -x
set -e

# Get Runtime Parameters
JSON_PARAMS="$1"
JSON=$(cat "$JSON_PARAMS")

echo "JSON parameters for Docker Compose coverage = $JSON"

# Get Project Name
PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")

# Get Container Names
export OSEE_CONTAINER="${PROJECT_NAME}"-osee-postgres-1
export POSTGRESQL_CONTAINER="${PROJECT_NAME}"-postgresql-1

# Get Active Ports
OSEE_PORT=$(docker inspect "${OSEE_CONTAINER}" | jq -r ".[].NetworkSettings.Ports.\"8089/tcp\"[0].HostPort")
POSTGRESQL_PORT=$(docker inspect "${POSTGRESQL_CONTAINER}" | jq -r ".[].NetworkSettings.Ports.\"5432/tcp\"[0].HostPort")
OSEE_WEB_URL="http://localhost:${OSEE_PORT}"

echo "OSEE_PORT = $OSEE_PORT"
echo "POSTGRESQL_PORT = $POSTGRESQL_PORT"
echo "OSEE_WEB_URL = $OSEE_WEB_URL"

# Set necessary permissions and run configuration updater
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

chmod 777 "${SCRIPTPATH}"/configs/config_updater.sh "${SCRIPTPATH}"/configs/pg_hba.conf
"${SCRIPTPATH}"/configs/config_updater.sh

# Copy configuration files to respective containers
docker cp "${SCRIPTPATH}"/configs/osee.postgresql.json "${OSEE_CONTAINER}":/var/osee/etc/osee.postgresql.json
docker cp "${SCRIPTPATH}"/configs/pg_hba.conf "${POSTGRESQL_CONTAINER}":/var/lib/postgresql/data/pg_hba.conf

# Restart PostgreSQL container to apply new configurations
docker restart "${POSTGRESQL_CONTAINER}"
sleep 10

# Run Coverage Commands

## Run OSEE on PostgreSQL
docker exec -d "${OSEE_CONTAINER}" /bin/bash "./runOSEEonP1.sh"
sleep 10

## Initialize Database with OSEE Schemas
curl -X POST -H "Content-Type: application/json" "http://localhost:${OSEE_PORT}/orcs/datastore/initialize"
sleep 10

## Verify Database Initialization
docker exec "${POSTGRESQL_CONTAINER}" psql -U osee -c "\dt"

## Run OSEE Demo Script
docker exec -d "${OSEE_CONTAINER}" /bin/bash "./runDemo.sh"
sleep 5

## Run Local PostgreSQL Instance
docker exec -d "${OSEE_CONTAINER}" /bin/bash "./runPostgreSqlLocal.sh"
sleep 5

## Run Local HSQL Instance
docker exec -d "${OSEE_CONTAINER}" /bin/bash "./runHsql.sh"
sleep 5

## Run OSEE Server Control Script
docker exec -d "${OSEE_CONTAINER}" /bin/bash "./runServer.sh"
sleep 5

echo "Coverage Completed Successfully"
