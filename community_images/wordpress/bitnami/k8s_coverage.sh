#!/bin/bash

set -x
set -e

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

JSON_PARAMS="$1"

NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")
RELEASE_NAME=$(jq -r '.release_name' < "$JSON_PARAMS")

WORDPRESS_SERVER="${RELEASE_NAME}"."${NAMESPACE}".svc.cluster.local

WORDPRESS_PORT='80'
"${SCRIPTPATH}"/../../common/selenium_tests/runner.sh "${WORDPRESS_SERVER}" "${WORDPRESS_PORT}" "${SCRIPTPATH}"/selenium_tests "${NAMESPACE}" 2>&1
