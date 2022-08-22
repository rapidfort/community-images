#!/bin/bash

set -x
set -e

if [[ $# -ne 3 ]]; then
    echo "Usage:$0 <server> <port> <selenium_test_dir>"
    exit 1
fi

echo "inputs=$1 $2 $3"

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

SERVER=$1
PORT=$2
SELENIUM_TEST_DIRECTORY=$3

cat "${SCRIPTPATH}"/selenium_pod.yaml | envsubst - | kubectl apply -f -
