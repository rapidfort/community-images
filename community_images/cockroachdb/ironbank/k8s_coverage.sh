#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")
NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")
RELEASE_NAME=$(jq -r '.release_name' < "$JSON_PARAMS")

curl -OOOOOOOOO https://raw.githubusercontent.com/cockroachdb/helm-charts/master/examples/client-secure.yaml

kubectl create -f ${SCRIPTPATH}/client-secure.yaml -n ${NAMESPACE}

kubectl exec -it \
	cockroachdb-client-secure \
	--namespace ${NAMESPACE} \
	-- ./cockroach sql --certs-dir=./cockroach-certs --host=rf-cockroachdb-ib-public \
	< ${SCRIPTPATH}/../../common/tests/test.psql

kubectl exec -it \
	cockroachdb-client-secure \
	--namespace ${NAMESPACE} \
	-- ./cockroach sql --certs-dir=./cockroach-certs --host=rf-cockroachdb-ib-public \
	< ${SCRIPTPATH}/coverage.psql

sleep 30


SERVER="${RELEASE_NAME}-public.${NAMESPACE}.svc.cluster.local"
PORT=3000

# Initiating Selenium tests
# "${SCRIPTPATH}"/../../common/selenium_tests/runner.sh "${SERVER}" "${PORT}" "${SCRIPTPATH}"/selenium_tests 2>&1
