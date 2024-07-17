#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker coverage = $JSON"

CONTAINER_NAME=$(jq -r '.container_details."trufflehog".name' < "$JSON_PARAMS")

# Scan Volume
docker exec -i "${CONTAINER_NAME}" /opt/trufflehog/trufflehog filesystem /proj 


# Scan online repo
docker exec -i "${CONTAINER_NAME}" /opt/trufflehog/trufflehog git https://github.com/trufflesecurity/test_keys

# Scan cloned repo
docker exec -i "${CONTAINER_NAME}" git clone https://github.com/trufflesecurity/test_keys
docker exec -i "${CONTAINER_NAME}" /opt/trufflehog/trufflehog filesystem test_keys

# Scan Comments in Github repo 
docker exec -i "${CONTAINER_NAME}" /opt/trufflehog/trufflehog github --repo=https://github.com/trufflesecurity/test_keys --issue-comments --pr-comments

# Scan a docker image 
docker exec -i "${CONTAINER_NAME}" /opt/trufflehog/trufflehog docker --image trufflesecurity/secrets --only-verified 

