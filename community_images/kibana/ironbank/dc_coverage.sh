#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")
CONTAINER_NAME=${PROJECT_NAME}-kibana-1

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

KIBANA_HOST=$(docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Networks.\"${PROJECT_NAME}_elastic\".IPAddress")
KIBANA_PORT='5601'

curl -XGET 'http://localhost:5601/api/status'

"${SCRIPTPATH}"/../../common/selenium_tests/runner-dc.sh "${KIBANA_HOST}" "${KIBANA_PORT}" "${SCRIPTPATH}"/selenium_tests 2>&1

curl -X POST "http://localhost:5601/api/saved_objects/index-pattern/your_index_pattern_id" -H "kbn-xsrf: true" -H "Content-Type: application/json" -d '
{
  "attributes": {
    "title": "Your Index Pattern Title",
    "timeFieldName": "timestamp_field_name"
  }
}'

curl -X PUT "http://localhost:9200/my_index" -H "Content-Type: application/json" -d '{
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 1
  },
  "mappings": {
    "properties": {
      "field1": { "type": "text" },
      "field2": { "type": "integer" }
      // Define other fields as needed
    }
  }
}'


curl -X POST "http://localhost:9200/my_index/_search" -H "Content-Type: application/json" -d '{
  "query": {
    "match_all": {}
  }
}'

