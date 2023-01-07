#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

SCRIPTPATH=$(jq -r '.image_script_dir' < "$JSON_PARAMS")
NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")
RELEASE_NAME=$(jq -r '.release_name' < "$JSON_PARAMS")

# get postgresql passwordk
POSTGRES_PASSWORD=$(kubectl get secret --namespace "${NAMESPACE}" "${RELEASE_NAME}" -o jsonpath="{.data.postgres-password}" | base64 --decode)

# copy test.psqlbi into container
kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/../../common/tests/test.psqlbi "${RELEASE_NAME}"-0:/tmp/test.psqlbi

# run script
kubectl -n "${NAMESPACE}" exec -i "${RELEASE_NAME}"-0 \
    -- /bin/bash -c "PGPASSWORD=${POSTGRES_PASSWORD} psql --host localhost -U postgres -d postgres -p 5432 -f /tmp/test.psqlbi"

# copy postgres_coverage.sh into container
kubectl -n "${NAMESPACE}" cp \
    "${SCRIPTPATH}"/../../common/tests/postgres_coverage.sh \
    "${RELEASE_NAME}"-0:/tmp/postgres_coverage.sh

# run postgres_coverage on cluster
kubectl -n "${NAMESPACE}" exec -i "${RELEASE_NAME}"-0 \
    -- /bin/bash -c "/tmp/postgres_coverage.sh"

# run postgres benchmark
kubectl run "${RELEASE_NAME}"-client --rm -i \
    --restart='Never' --namespace "${NAMESPACE}" \
    --image rapidfort/postgresql:latest \
    --env="PGPASSWORD=$POSTGRES_PASSWORD" --command \
    -- pgbench --host "${RELEASE_NAME}" -U postgres -d postgres -p 5432 -i -s 50
