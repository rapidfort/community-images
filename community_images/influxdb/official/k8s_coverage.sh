#!/bin/bash

set -x
set -e

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

JSON_PARAMS="$1"

NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")
RELEASE_NAME=$(jq -r '.release_name' < "$JSON_PARAMS")
REPOSITORY=influxdb

# get pod name
POD_NAME=$(kubectl -n "${NAMESPACE}" get pods -l app.kubernetes.io/name="$REPOSITORY" -o jsonpath="{.items[0].metadata.name}")

# get influxdb token
INFLUXDB_TOKEN=$(kubectl get secret --namespace "${NAMESPACE}" "${RELEASE_NAME}" -o jsonpath="{.data.admin-user-token}" | base64 --decode)

# copy tests into container
kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/tests/example.csv "${POD_NAME}":/tmp/example.csv
kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/tests/query.flux "${POD_NAME}":/tmp/query.flux

# write data to db
kubectl -n "${NAMESPACE}" exec -it "${POD_NAME}" -- /bin/bash -c "influx write -t $INFLUXDB_TOKEN -b primary --org-id primary -f /tmp/example.csv"

# run query on db
kubectl -n "${NAMESPACE}" exec -i "${POD_NAME}" -- influx query -t "$INFLUXDB_TOKEN" --org primary -f /tmp/query.flux
