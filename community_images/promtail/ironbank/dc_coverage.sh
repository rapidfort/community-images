#!/bin/bash

set -ex

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/scripts/bash_helper.sh

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "JSON = $JSON"

# Tempo coverage

# if it fails run `date +%s%8N` to get current time in mills
# and add it to `startTimeUnixNano` and `endTimeUnixNano`(Add some milliseconds to it)
# make the length same as present now by appending zeros
curl -X POST -H 'Content-Type: application/json' http://localhost:4318/v1/traces -d '
{
	"resourceSpans": [{
    	"resource": {
        	"attributes": [{
            	"key": "service.name",
            	"value": {
                	"stringValue": "my.service"
            	}
        	}]
    	},
    	"scopeSpans": [{
        	"scope": {
            	"name": "my.library",
            	"version": "1.0.0",
            	"attributes": [{
                	"key": "my.scope.attribute",
                	"value": {
                    	"stringValue": "some scope attribute"
                	}
            	}]
        	},
        	"spans": [
        	{
            	"traceId": "5B8EFFF798038103D269B633813FC700",
            	"spanId": "EEE19B7EC3C1B100",
            	"name": "I am a span!",
            	"startTimeUnixNano": 1710353044840697810,
            	"endTimeUnixNano": 1710353075445445600,
            	"kind": 2,
            	"attributes": [
            	{
                	"key": "my.span.attr",
                	"value": {
                    	"stringValue": "some value"
                	}
            	}]
        	}]
    	}]
	}]
}'

curl http://localhost:3200/api/traces/5b8efff798038103d269b633813fc700

curl -G -s http://localhost:3200/api/search --data-urlencode 'q={ .service.name = "my.service" }'

# Grafana and ui
PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")
CONTAINER_NAME=${PROJECT_NAME}-grafana-1

HOST=$(docker inspect "${CONTAINER_NAME}" | jq -r ".[].NetworkSettings.Networks.\"${PROJECT_NAME}_default\".IPAddress")
PORT=3000

# Initiating Selenium tests
echo "Running Selenium tests"
("${SCRIPTPATH}"/../../common/selenium_tests/runner-dc.sh \
	"${HOST}" "${PORT}" "${SCRIPTPATH}"/selenium_tests 2>&1) >&2

# Curl coverage for loki explorer
bash "${SCRIPTPATH}/curl_coverage.sh"

echo "Grafana cli coverage"
GRAFANA_CONTAINER=${PROJECT_NAME}-grafana-1
docker exec "${GRAFANA_CONTAINER}" grafana cli -h

# Restart to setup and load plugins installed.
docker restart "${GRAFANA_CONTAINER}"
sleep 30
