#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")
CONTAINER_NAME=${PROJECT_NAME}-metricbeat-1

sleep 40
# testing commands
docker exec "${CONTAINER_NAME}" bin/bash /tmp/test_commands.sh
# indices present 
curl -XGET 'http://localhost:9200/_cat/indices?v&pretty'
#To verify that your server’s statistics are present in Elasticsearch
curl -XGET 'http://localhost:9200/metricbeat-*/_search?pretty'

"${SCRIPTPATH}"/../../common/selenium_tests/runner-dc.sh "dummy" "dummy" "${SCRIPTPATH}"/selenium_tests 2>&1

