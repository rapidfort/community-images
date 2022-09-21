#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")
echo "Json params for docker compose coverage = $JSON"

SCRIPTPATH=$(jq -r '.image_script_dir' < "$JSON_PARAMS")

# PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")
"${SCRIPTPATH}"/mc_cli.sh 127.0.0.1 11211 "set test_key 0 60 10"$'\n'"0123456789"
"${SCRIPTPATH}"/mc_cli.sh 127.0.0.1 11211 "get test_key"
"${SCRIPTPATH}"/mc_cli.sh 127.0.0.1 11211 "replace test_key 0 100 11"$'\n'"Hello World"
"${SCRIPTPATH}"/mc_cli.sh 127.0.0.1 11211 "get test_key"
"${SCRIPTPATH}"/mc_cli.sh 127.0.0.1 11211 "delete test_key"
"${SCRIPTPATH}"/mc_cli.sh 127.0.0.1 11211 "stats"
"${SCRIPTPATH}"/mc_cli.sh 127.0.0.1 11211 "stats items"
