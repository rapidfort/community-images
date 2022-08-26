#!/bin/bash

set -x
set -e

if [[ -z "$SERVER" ]]; then
    echo "Must provide SERVER in environment" 1>&2
    exit 1
fi

if [[ -z "$PORT" ]]; then
    echo "Must provide PORT in environment" 1>&2
    exit 1
fi


# shellcheck source=community_images/common/scripts/bash_helper.sh
source /usr/workspace/bash_helper.sh

# show folders
ls -lR /usr/workspace/

# cd into tests folder
cd /usr/workspace/selenium_tests/

# run pytest
echo pytest -s /usr/workspace/selenium_tests/ --server "$SERVER" --port "$PORT"
sleep infinity
