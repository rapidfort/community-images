#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker coverage = $JSON"

CONTAINER_NAME=$(jq -r '.container_details["ansible-lint-ib"].name' < "$JSON_PARAMS")

docker exec \
    -i "$CONTAINER_NAME" \
    ansible-lint --help

# linting geerlingguy.apache role
docker exec \
    -i "$CONTAINER_NAME" \
    ansible-lint geerlingguy.apache || true
docker exec \
    -i "$CONTAINER_NAME" \
    ansible-lint -p geerlingguy.apache || true

# linting playbook
docker exec \
    -i "$CONTAINER_NAME" \
    ansible-lint sample_playbook.yml || true

# passing config file
docker exec \
    -i "$CONTAINER_NAME" \
    ansible-lint sample_playbook.yml -c ./config_file/.ansible-lint || true

# shows the available tags in an example set of rules, and the rules associated with each tag
docker exec \
    -i "$CONTAINER_NAME" \
    ansible-lint -v -T

# running just idempotency rules
docker exec \
    -i "$CONTAINER_NAME" \
    ansible-lint -t idempotency sample_playbook.yml || true

# run all of the rules except those with the tags readability and safety
docker exec \
    -i "$CONTAINER_NAME" \
    ansible-lint -x readability,safety sample_playbook.yml || true

# output in different formats
docker exec \
    -i "$CONTAINER_NAME" \
    ansible-lint --offline -q -f pep8 sample_playbook.yml || true
docker exec \
    -i "$CONTAINER_NAME" \
    ansible-lint --offline -q -f sarif sample_playbook.yml || true
docker exec \
    -i "$CONTAINER_NAME" \
    ansible-lint --offline -q -f json sample_playbook.yml || true

# profiles
docker exec \
    -i "$CONTAINER_NAME" \
    ansible-lint --list-profiles
