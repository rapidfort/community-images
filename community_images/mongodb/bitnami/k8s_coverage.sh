#!/bin/bash

set -x
set -e

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/mongo_helpers.sh

JSON_PARAMS="$1"

NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")
RELEASE_NAME=$(jq -r '.release_name' < "$JSON_PARAMS")

# get pod name
POD_NAME=$(kubectl -n "${NAMESPACE}" get pods -l app.kubernetes.io/name=mongodb -o jsonpath="{.items[0].metadata.name}")
# copy mongodb_coverage.sh into container
kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/../../common/tests/mongodb_coverage.sh "${POD_NAME}":/tmp/mongodb_coveragesh

# run mongodb_coverage on cluster
kubectl -n "${NAMESPACE}" exec -i "${POD_NAME}" -- /bin/bash -c "/tmp/mongodb_coverage.sh"

# get mongodb password
MONGODB_ROOT_PASSWORD=$(kubectl get secret --namespace "${NAMESPACE}" "${HELM_RELEASE}" -o jsonpath="{.data.mongodb-root-password}" | base64 --decode)
# create MongoDB client
MONGODB_ROOT_PASSWORD="${MONGODB_ROOT_PASSWORD}" \
    IMAGE_REPOSITORY="${IMAGE_REPOSITORY}" \
    TAG="${TAG}" envsubst < "${SCRIPTPATH}"/client.yml.base | kubectl -n "${NAMESPACE}" apply -f -

# wait for mongodb client to be ready
kubectl wait pods "${RELEASE_NAME}"-client -n "${NAMESPACE}" --for=condition=ready --timeout=10m

# copy test.mongo into container
kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/../../common/tests/test.mongo "${RELEASE_NAME}"-client:/tmp/test.mongo

# run script
kubectl -n "${NAMESPACE}" exec -i "${RELEASE_NAME}"-client \
    -- /bin/bash -c "mongosh admin --host \"mongodb-release\" \
    --authenticationDatabase admin -u root -p ${MONGODB_ROOT_PASSWORD} --file /tmp/test.mongo"

# delete client container
kubectl -n "${NAMESPACE}" delete pod "${RELEASE_NAME}"-client

# run MongoDB tests
k8s_perf_runner "${NAMESPACE}" INSERT "${RELEASE_NAME}" "${MONGODB_ROOT_PASSWORD}"
k8s_perf_runner "${NAMESPACE}" UPDATE_MANY "${RELEASE_NAME}" "${MONGODB_ROOT_PASSWORD}"
k8s_perf_runner "${NAMESPACE}" ITERATE_MANY "${RELEASE_NAME}" "${MONGODB_ROOT_PASSWORD}"
k8s_perf_runner "${NAMESPACE}" DELETE_MANY "${RELEASE_NAME}" "${MONGODB_ROOT_PASSWORD}"