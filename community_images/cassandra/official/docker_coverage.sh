#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker coverage = $JSON"

RAPIDFORT_ACCOUNT="${RAPIDFORT_ACCOUNT:-rapidfort}"
NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")

# get docker host ip
#CASSANDRA_HOST=$(jq -r '.container_details."cassandra-official".ip_address' < "$JSON_PARAMS")
REPO_PATH=$(jq -r '.image_tag_details."cassandra-official".repo_path' < "$JSON_PARAMS")
TAG=$(jq -r '.image_tag_details."cassandra-official".tag' < "$JSON_PARAMS")

# run docker
docker run --rm -i --cap-add=SYS_PTRACE --name="${NAMESPACE}"-"$(date +%s)" -d "${REPO_PATH}:${TAG}"
