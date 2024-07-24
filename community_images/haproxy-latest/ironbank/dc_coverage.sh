#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/scripts/bash_helper.sh

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

# Parse version from JSON or environment variable
VERSION=$(jq -r '.version' <<< "$JSON")
# If the version is not in JSON, you can alternatively set it as an environment variable
# VERSION="${HAPROXY_IMAGE_TAG}"

# roundrobin mode
CONTAINER1_NAME=haproxy-1
# leastconn mode
CONTAINER2_NAME=haproxy-2
# source mode
CONTAINER3_NAME=haproxy-3
# quic protocol tests (only for version 3.0+)
CONTAINER4_NAME=haproxy-quic

# log for debugging
docker inspect "${CONTAINER1_NAME}"
docker inspect "${CONTAINER2_NAME}"
docker inspect "${CONTAINER3_NAME}"

# finding ports
docker inspect "${CONTAINER1_NAME}" | jq -r ".[].NetworkSettings.Ports.\"80/tcp\"[0].HostPort"
PORT1=$(docker inspect "${CONTAINER1_NAME}" | jq -r ".[].NetworkSettings.Ports.\"80/tcp\"[0].HostPort")
docker inspect "${CONTAINER2_NAME}" | jq -r ".[].NetworkSettings.Ports.\"80/tcp\"[0].HostPort"
PORT2=$(docker inspect "${CONTAINER2_NAME}" | jq -r ".[].NetworkSettings.Ports.\"80/tcp\"[0].HostPort")
docker inspect "${CONTAINER3_NAME}" | jq -r ".[].NetworkSettings.Ports.\"80/tcp\"[0].HostPort"
PORT3=$(docker inspect "${CONTAINER3_NAME}" | jq -r ".[].NetworkSettings.Ports.\"80/tcp\"[0].HostPort")

# run curl in loop (roundrobin)
for i in {1..10}; do 
    echo "Attempt $i"
    curl http://localhost:"${PORT1}"
done

# run curl in loop for app1 route
for i in {1..10}; do 
    echo "Attempt $i"
    curl http://localhost:"${PORT1}"/app1
done

# run curl in loop for app2 route
for i in {1..10}; do 
    echo "Attempt $i"
    curl http://localhost:"${PORT1}"/app2
done

# Running curl for admin (disabled by acl)
curl http://localhost:"${PORT1}"/admin

# run curl in loop (leastconn)
for i in {1..10}; do 
    echo "Attempt $i"
    curl http://localhost:"${PORT2}"
done

# run curl in loop (source)
for i in {1..10}; do 
    echo "Attempt $i"
    curl http://localhost:"${PORT3}"
done

# Additional tests for version 3.0+
if [[ "$VERSION" =~ ^3 ]]; then
    docker inspect "${CONTAINER4_NAME}"
    docker inspect "${CONTAINER4_NAME}" | jq -r ".[].NetworkSettings.Ports.\"443/tcp\"[0].HostPort"
    PORT4=$(docker inspect "${CONTAINER4_NAME}" | jq -r ".[].NetworkSettings.Ports.\"443/tcp\"[0].HostPort")

    # QUIC Testing
    for i in {1..10}; do
        echo "HTTP/2 Attempt $i"
        curl --http2 -k https://localhost:"${PORT4}"
    done
fi