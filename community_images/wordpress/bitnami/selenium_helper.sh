#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

function test_selenium() {
    local NAMESPACE=$1
    local WORDPRESS_SERVER=$2

    # get the ip address of wordpress service
    WORDPRESS_IP=$(kubectl get nodes --namespace "${NAMESPACE}" -o jsonpath="{.items[0].status.addresses[0].address}")
    ports=$(kubectl get svc --namespace "${NAMESPACE}" -o go-template='{{range .items}}{{range.spec.ports}}{{if .nodePort}}{{.nodePort}}{{"\n"}}{{end}}{{end}}{{end}}')
    WORDPRESS_PORT=$(echo "$ports" | head -n 1)

    echo "wordpress IP is $WORDPRESS_IP"
    echo "wordpress port is $WORDPRESS_PORT"

    WORDPRESS_IP=$WORDPRESS_SERVER
    WORDPRESS_PORT='80'

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
    pip install pytest
    pip install selenium
    pytest -s /tmp/wordpress_selenium_test.py --ip_address $WORDPRESS_IP --port $WORDPRESS_PORT" > "$SCRIPTPATH"/commands.sh
    kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/conftest.py "${CHROME_POD}":/tmp/conftest.py
    kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/wordpress_selenium_test.py "${CHROME_POD}":/tmp/wordpress_selenium_test.py
    chmod +x "$SCRIPTPATH"/commands.sh
    kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/commands.sh "${CHROME_POD}":/tmp/common_commands.sh

    kubectl -n "${NAMESPACE}" exec -i "${CHROME_POD}" -- bash -c "/tmp/common_commands.sh"
    # delete the generated commands.sh
    rm "$SCRIPTPATH"/commands.sh

    # delete the cloned directory
    rm -rf "${SCRIPTPATH}"/docker-python-chromedriver
}
