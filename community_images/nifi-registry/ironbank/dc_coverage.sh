#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/scripts/bash_helper.sh

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")

CONTAINER_NAME="${PROJECT_NAME}"-nifi-registry-1
echo "${CONTAINER_NAME}"
sleep 10
curl http://localhost:18080/nifi-registry
# bucket creation
curl -s -X POST -H "Content-Type: application/json" -d '{"name":"test-bucket"}' http://localhost:18080/nifi-registry-api/buckets > /dev/null

# identifier=$(curl -s http://localhost:18080/nifi-registry-api/buckets | jq '.[].identifier')
identifier=$(curl -s http://localhost:18080/nifi-registry-api/buckets | jq -r '.[0].identifier')
# flow creation
curl -s -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "name": "My Flow",
    "description": "Description of my flow",
    "bucketIdentifier": "'"${identifier}"'",
    "flow": {
        "processGroups": [
            {
                "name": "My Process Group",
                "position": {"x": 100, "y": 100},
                "comments": "My process group description"
            }
        ]
    }
}' "http://localhost:18080/nifi-registry-api/buckets/""${identifier}""/flows"

curl -s http://localhost:18080/nifi-registry-api/buckets
curl -s http://localhost:18080/nifi-registry-api/buckets/"${identifier}"/flows

curl -s http://localhost:18080/nifi-registry-api/bundles
#deleting bucket
curl -X DELETE http://localhost:18080/nifi-registry-api/buckets/"${identifier}"
