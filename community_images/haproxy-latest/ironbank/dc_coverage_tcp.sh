#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/scripts/bash_helper.sh

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

# identity mode
CONTAINER1_NAME=haproxy-1
# gzip mode
CONTAINER2_NAME=haproxy-2
# deflate mode
CONTAINER3_NAME=haproxy-3

# log for debugging
docker inspect "${CONTAINER1_NAME}"
docker inspect "${CONTAINER2_NAME}"
docker inspect "${CONTAINER3_NAME}"

# finding ports
PORT1=$(docker inspect "${CONTAINER1_NAME}" | jq -r ".[].NetworkSettings.Ports.\"80/tcp\"[0].HostPort")
PORT2=$(docker inspect "${CONTAINER2_NAME}" | jq -r ".[].NetworkSettings.Ports.\"80/tcp\"[0].HostPort")
PORT3=$(docker inspect "${CONTAINER3_NAME}" | jq -r ".[].NetworkSettings.Ports.\"80/tcp\"[0].HostPort")

# run curl in loop (identity)
for i in {1..5}; do 
    echo "Attempt $i"
    curl http://localhost:"${PORT1}"
done

# run curl in loop (gzip)
for i in {1..5}; do 
    echo "Attempt $i"
    curl http://localhost:"${PORT2}"
done

# run curl in loop (deflate)
for i in {1..5}; do 
    echo "Attempt $i"
    curl http://localhost:"${PORT3}"
done

# Test dynamic SSL certificate updates
printf "set ssl cert /etc/ssl/private/haproxy.pem <<\n$(cat /path/to/new/cert.pem)\n" | socat stdio /var/run/haproxy.sock
printf "commit ssl cert /etc/ssl/private/haproxy.pem" | socat stdio /var/run/haproxy.sock

# Test dynamic server weight adjustment
printf "set server be_servers/server1 weight 20" | socat stdio /var/run/haproxy.sock
printf "set server be_servers/server2 weight 5" | socat stdio /var/run/haproxy.sock

# Observability Testing (Metrics)
echo "Fetching metrics"
curl http://localhost:8404/metrics
