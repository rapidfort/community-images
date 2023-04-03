#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/scripts/bash_helper.sh

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")

CONTAINER_NAME="${PROJECT_NAME}"-microsoft-sql-server-1

# Running tests
docker cp "${SCRIPTPATH}"/tests/azure_ib.ms_sql "${CONTAINER_NAME}":/tmp/test1.ms_sql
docker exec -i "${CONTAINER_NAME}" /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P 'DevPass123!' -i "./tmp/test1.ms_sql"

# Running backup functionality test
docker cp "${SCRIPTPATH}"/tests/azure_ib.ms_sql "${CONTAINER_NAME}":/tmp/test2.ms_sql
docker exec -i "${CONTAINER_NAME}" /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P 'DevPass123!' -i "./tmp/test2.ms_sql"