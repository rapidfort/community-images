#!/bin/bash

set -x
set -e

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

JSON_PARAMS=$1
JSON=$(cat "$JSON_PARAMS")

echo "Json params for k8s coverage = $JSON"

NAMESPACE_NAME=$(jq -r '.namespace_name' < "$JSON_PARAMS")
CONTAINER_NAME="mkdocs-ib-${NAMESPACE_NAME}"
MKDOCS_PORT=5678

# Start mkdocs server
docker exec -i "${CONTAINER_NAME}" mkdocs -v serve --dev-addr=0.0.0.0:${MKDOCS_PORT} &
MKDOCS_PID=$!

# Run a background process to watch "reload.txt" file in python-chromedriver 
# and then update any file in mkdocs to trigger live reload
(
sleep 30 # sleep to compensate sleep 30 in selenium_tests
for ((i = 0; i < 10; i++)); do
  sleep 1
  if [[ $(docker exec -i python-chromedriver cat /usr/workspace/selenium_tests/reload.txt || echo "not-found") == *reload* ]]; then
    echo "watch[$i] - signal file found \"reload.txt\""
    touch "${SCRIPTPATH}/docs/mkdocs.yml"

    exit 0
  else
    echo "watch[$i] - singal file not found \"reload.txt\""
  fi
done
) &

# Run selenium tests
("${SCRIPTPATH}"/../../common/selenium_tests/runner-dc.sh "localhost" "${MKDOCS_PORT}" "${SCRIPTPATH}"/selenium_tests 2>&1) >&2

kill -s 15 "${MKDOCS_PID}"  # Send SIGTERM to mkdocs process

# Mkdocs get dependencies
docker exec -i "${CONTAINER_NAME}" mkdocs get-deps

# Initialize new MkDocs project
docker exec -i "${CONTAINER_NAME}" mkdir /tmp/new-docs
docker exec -i "${CONTAINER_NAME}" mkdocs new /tmp/new-docs

# Build with different themes
docker exec -i "${CONTAINER_NAME}" bash -c "cd /tmp/new-docs; mkdocs build --clean --theme mkdocs"
docker exec -i "${CONTAINER_NAME}" bash -c "cd /tmp/new-docs; mkdocs build --clean --theme readthedocs"

# Deploy as github pages (will fail)
docker exec -i "${CONTAINER_NAME}" mkdocs gh-deploy -b mkdocs-deploy || true

