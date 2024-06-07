#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

# Fetch complete Image Name
REPO_NAME=$(jq -r '.image_tag_details."nginx-official"."repo_path"' < "$JSON_PARAMS")
TAG=$(jq -r '.image_tag_details."nginx-official"."tag"' < "$JSON_PARAMS")
IMAGE_NAME="${REPO_NAME}:${TAG}"

# If nginx image is slim, it won't contain modules
if [[ $IMAGE_NAME == *"slim"* ]]; then
    cp "${SCRIPTPATH}/configs/nginx.conf.without_load_modules" \
       "${SCRIPTPATH}/configs/nginx.conf"
else
    cp "${SCRIPTPATH}/configs/nginx.conf.load_modules" \
       "${SCRIPTPATH}/configs/nginx.conf"
fi