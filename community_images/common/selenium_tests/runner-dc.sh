#!/bin/bash

set -x
set -e

if [[ $# -ne 3 ]]; then
    echo "Usage:$0 <server> <port> <selenium_test_dir>"
    exit 1
fi

echo "inputs=$1 $2 $3"

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

export SERVER="$1"
export PORT="$2"
SELENIUM_TEST_DIRECTORY="$3"

# Deploying python-chromedriver container
docker-compose -f "$SCRIPTPATH"/docker-compose.yml up -d
docker cp "$SELENIUM_TEST_DIRECTORY"/ python-chromedriver:/usr/workspace/
# Running selenium script
docker exec -i python-chromedriver bash -c "/usr/workspace/entrypoint.sh"
docker-compose -f "$SCRIPTPATH"/docker-compose.yml down
