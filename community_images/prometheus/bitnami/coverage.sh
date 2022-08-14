#!/bin/bash

set -e
set -x

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
RAPIDFORT_ACCOUNT="${RAPIDFORT_ACCOUNT:-rapidfort}"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/retry_helper.sh

function get_unused_port() {
    while
     port=$(shuf -n 1 -i 49152-65535)
     netstat -atun | grep -q "$port"
    do
     continue
    done

    echo "$port"
}

function test_prometheus() {
    local NAMESPACE=$1
    local PROMETHEUS_SERVER=$2
    local PROMETHEUS_PORT=$3

    FLASK_POD_NAME="flaskapp"
    FLASK_LOCAL_PORT=get_unused_port

    kubectl run "${FLASK_POD_NAME}" --restart='Never' --image "${RAPIDFORT_ACCOUNT}"/flaskapp --namespace "${NAMESPACE}"
    # wait for flask app pod to come up
    kubectl wait pods "${FLASK_POD_NAME}" -n "${NAMESPACE}" --for=condition=ready --timeout=10m
    # port forward the pod to the host machine
    kubectl port-forward "${FLASK_POD_NAME}" "${FLASK_LOCAL_PORT}":5000 --namespace "${NAMESPACE}" &

    # hit the flaskapp endpoints so that prometheus metrics are published
    for i in {1..10}; do
        echo "attempt $i"
        with_backoff curl -L http://localhost:"${FLASK_LOCAL_PORT}"/test
        with_backoff curl -L http://localhost:"${FLASK_LOCAL_PORT}"/test1
        sleep 1
    done

    # wait for 10 secs for the metrics to be scraped and published
    sleep 10

    CHROME_POD="python-chromedriver"
    # delete the directory if present already
    rm -rf "${SCRIPTPATH}"/docker-python-chromedriver
    # delete the pod if present already, this sometimes happens if the cleanup didn't happen properly and is transient
    kubectl delete pod "${CHROME_POD}" --namespace "${NAMESPACE}" --ignore-not-found=true
    # clone the docker python chromedriver repo
    git clone https://github.com/joyzoursky/docker-python-chromedriver.git "${SCRIPTPATH}"/docker-python-chromedriver
    # cd docker-python-chromedriver
    kubectl run "${CHROME_POD}" --restart='Never' --image joyzoursky/"${CHROME_POD}":latest --namespace "${NAMESPACE}" --command -- sleep infinity

    kubectl wait pods "${CHROME_POD}" -n "${NAMESPACE}" --for=condition=ready --timeout=10m
    kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/docker-python-chromedriver "${CHROME_POD}":/usr/workspace

    echo "#!/bin/bash
    cd /usr/workspace
    . /tmp/helpers.sh
    pip install pytest
    pip install selenium
    with_backoff pytest -s /tmp/prometheus_selenium_test.py --prom_server $PROMETHEUS_SERVER --port $PROMETHEUS_PORT" > "$SCRIPTPATH"/commands.sh
    kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/conftest.py "${CHROME_POD}":/tmp/conftest.py
    kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/prometheus_selenium_test.py "${CHROME_POD}":/tmp/prometheus_selenium_test.py
    chmod +x "$SCRIPTPATH"/commands.sh
    kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/commands.sh "${CHROME_POD}":/tmp/common_commands.sh
    kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/../../common/retry_helper.sh "${CHROME_POD}":/tmp/helpers.sh

    kubectl -n "${NAMESPACE}" exec -i "${CHROME_POD}" -- bash -c "/tmp/common_commands.sh"
    # delete the generated commands.sh
    rm "$SCRIPTPATH"/commands.sh

    # delete the cloned directory
    rm -rf "${SCRIPTPATH}"/docker-python-chromedriver

    # delete the pods
    kubectl delete pod "${FLASK_POD_NAME}" --namespace "${NAMESPACE}"
    kubectl delete pod "${CHROME_POD}" --namespace "${NAMESPACE}"
}
