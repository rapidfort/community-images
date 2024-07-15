#!/bin/bash

set -x
set -e

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/coverage.sh

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for k8s coverage = $JSON"

NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")
RELEASE_NAME=$(jq -r '.release_name' < "$JSON_PARAMS")

POD_NAME=$(kubectl get pods -n $NAMESPACE | grep "${RELEASE_NAME}-sidekiq-all-in-1-v2" | awk '{ print $1 }')

CONTAINER_NAME="sidekiq"

sleep 60

# copy over the script to the pod
kubectl cp -n "${NAMESPACE}" "${SCRIPTPATH}/scripts/sidekiq_coverage.sh" "${POD_NAME}:/srv/gitlab/coverage_script.sh" -c "${CONTAINER_NAME}"

kubectl cp -n "${NAMESPACE}" "${SCRIPTPATH}/scripts/gitlab_sidekiq_worker.rb" "${POD_NAME}:/srv/gitlab/app/workers/complex_user_activity_worker.rb" -c "${CONTAINER_NAME}"

test_sidekiq "${POD_NAME}" "${NAMESPACE}" "${CONTAINER_NAME}"