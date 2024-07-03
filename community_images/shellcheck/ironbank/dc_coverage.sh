#!/bin/bash

set -ex

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

echo "JSON = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")
CONTAINER_NAME="${PROJECT_NAME}"-shellcheck-1

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/coverage.sh

# Test shellcheck with a "good" script
echo "Running test_shellcheck_success"
test_shellcheck_success "${CONTAINER_NAME}"

# Test shellcheck with a "bad" script
echo "Running test_shellcheck_failure"
test_shellcheck_failure "${CONTAINER_NAME}"

# More shellcheck tests

# Incorrect quoting test
echo "Running test_shellcheck2"
test_shellcheck2 "${CONTAINER_NAME}"

# Incorrect test statements test
echo "Running test_shellcheck3"
test_shellcheck3 "${CONTAINER_NAME}"

# Misused commands (e.g misused exec)
echo "Running test_shellcheck4"
test_shellcheck4 "${CONTAINER_NAME}"

# Syntax error test
echo "Running test_shellcheck5"
test_shellcheck5 "${CONTAINER_NAME}"

# Unrecognized issues
echo "Running test_shellcheck6"
test_shellcheck6 "${CONTAINER_NAME}"
