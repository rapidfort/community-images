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
    local NAMESPACE=$1
    local PROMETHEUS_SERVER=$2
    local PROMETHEUS_PORT=$3

    FLASK_POD_NAME="flaskapp"
    FLASK_LOCAL_PORT=$(get_unused_port)

    kubectl run "${FLASK_POD_NAME}" --restart='Never' --image rapidfort/flaskapp --namespace "${NAMESPACE}"

    # wait for flask app pod to come up
    kubectl wait pods "${FLASK_POD_NAME}" -n "${NAMESPACE}" --for=condition=ready --timeout=10m

    # port forward the pod to the host machine
    kubectl port-forward "${FLASK_POD_NAME}" "${FLASK_LOCAL_PORT}":5000 --namespace "${NAMESPACE}" &
    PID_PF="$!"

    # hit the flaskapp endpoints so that prometheus metrics are published
    for i in {1..10}; do
        echo "attempt $i"
        with_backoff curl -L http://localhost:"${FLASK_LOCAL_PORT}"/test
        with_backoff curl -L http://localhost:"${FLASK_LOCAL_PORT}"/test1
        sleep 1
    done

    # wait for 10 secs for the metrics to be scraped and published
    sleep 10

    # run selenium tests
    "${SCRIPTPATH}"/../../common/selenium_tests/runner.sh "${PROMETHEUS_SERVER}" "${PROMETHEUS_PORT}" "${SCRIPTPATH}"/selenium_tests "${NAMESPACE}" 2>&1


    # delete pod
    kubectl delete pod "${FLASK_POD_NAME}" -n "${NAMESPACE}"

    # kill pid
    kill -9 "$PID_PF"

}
