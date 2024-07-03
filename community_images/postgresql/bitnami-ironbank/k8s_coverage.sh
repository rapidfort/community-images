#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

SCRIPTPATH=$(jq -r '.image_script_dir' < "$JSON_PARAMS")
NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")
RELEASE_NAME=$(jq -r '.release_name' < "$JSON_PARAMS")

sleep 30

# get postgresql passwordk
POSTGRES_PASSWORD="PgSQL@1234"
# copy test.psql into container
kubectl -n "${NAMESPACE}" exec -i "${RELEASE_NAME}" \
    -- /bin/bash -c 'cat > /tmp/test.psql' < "${SCRIPTPATH}"/../../common/tests/test.psql

# run script
kubectl -n "${NAMESPACE}" exec -i "${RELEASE_NAME}" \
    -- /bin/bash -c "PGPASSWORD=${POSTGRES_PASSWORD} psql --host localhost -U postgres -d postgres -p 5432 -f /tmp/test.psql"

# run postgres_coverage on cluster
kubectl -n "${NAMESPACE}" exec -i "${RELEASE_NAME}" \
    -- /bin/bash < "${SCRIPTPATH}"/../../common/tests/postgres_coverage.sh
