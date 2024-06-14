#!/bin/bash

set -e
set -x

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/scripts/bash_helper.sh

function get_unused_port() {
    netstat -aln | awk '
      $6 == "LISTEN" {
        if ($4 ~ "[.:][0-9]+$") {
          split($4, a, /[:.]/);
          port = a[length(a)];
          p[port] = 1
        }
      }
      END {
        for (i = 3000; i < 65000 && p[i]; i++){};
        if (i == 65000) {exit 1};
        print i
      }
    '
}

function test_prometheus() {
    local CONTAINER_NAME=$1
    local PROMETHEUS_HOST=$2
    local PROMETHEUS_PORT=$3
    
    echo "$CONTAINER_NAME"
    echo "$PROMETHEUS_HOST"
    echo "$PROMETHEUS_PORT"
    FLASK_LOCAL_PORT=$(get_unused_port)
    FLASK_CONTAINER_NAME="flaskapp"

    # Run the Flask app container
    docker run -d --name "${FLASK_CONTAINER_NAME}" -p "${FLASK_LOCAL_PORT}:5000" rapidfort/flaskapp

    # Wait for the Flask app to be ready
    echo "Waiting for the Flask app to start..."
    sleep 10  # Adjust the sleep time if needed

    # Hit the Flask app endpoints so that Prometheus metrics are published
    for i in {1..10}; do
        echo "attempt $i"
        with_backoff curl -L http://localhost:"${FLASK_LOCAL_PORT}"/test
        with_backoff curl -L http://localhost:"${FLASK_LOCAL_PORT}"/test1
        sleep 1
    done

    # Wait for 10 seconds for the metrics to be scraped and published
    sleep 10
}

