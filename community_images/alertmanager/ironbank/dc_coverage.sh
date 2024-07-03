#!/bin/bash

set -ex

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/scripts/bash_helper.sh

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "JSON = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")
CONTAINER_NAME="${PROJECT_NAME}"-alertmanager-1

#alerts
curl -XPOST -H "Content-Type: application/json" -d '[
  {
    "labels": {
      "alertname": "TestAlert",
      "severity": "critical"
    },
    "annotations": {
      "summary": "This is a test alert"
    }
  }
]' http://localhost:9093/api/v2/alerts

curl -s http://localhost:9093/api/v2/alerts
curl -s http://localhost:9093/api/v2/alerts | jq -r '.[].labels.alertname'

#silences
curl -XPOST -H "Content-Type: application/json" -d '{
  "matchers": [
    {
      "name": "alertname",
      "value": "TestAlert2",
      "isRegex": false
    }
  ],
  "startsAt": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'",
  "endsAt": "'$(date -u -d '+5 minutes' +"%Y-%m-%dT%H:%M:%SZ")'",
  "comment": "Silencing TestAlert2 for testing purposes",
  "createdBy": "test_script"
}' http://localhost:9093/api/v2/silences

curl -s http://localhost:9093/api/v2/silences | jq .
