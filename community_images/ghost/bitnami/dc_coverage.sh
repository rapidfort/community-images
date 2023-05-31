#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/scripts/bash_helper.sh

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

REPO_PATH=$(jq -r '.image_tag_details."ghost".repo_path' < "$JSON_PARAMS")
TAG=$(jq -r '.image_tag_details."ghost".tag' < "$JSON_PARAMS")

# run docker for GHOST SMTP Mode
# create network and mysql db
docker network create ghost-network
docker run -d --name mysql-check \
  --env ALLOW_EMPTY_PASSWORD=yes \
  --env MYSQL_USER=bn_ghost \
  --env MYSQL_PASSWORD=bitnami \
  --env MYSQL_DATABASE=bitnami_ghost \
  --network ghost-network bitnami/mysql:latest
# Create ghost container
docker run --rm -i --cap-add=SYS_PTRACE --name ghost-smtp -d\
  --env GHOST_DATABASE_USER=bn_ghost \
  --env GHOST_DATABASE_NAME=bitnami_ghost \
  --env GHOST_SMTP_HOST=smtp.gmail.com \
  --env GHOST_SMTP_PORT=587 \
  --env GHOST_SMTP_USER=your_email@gmail.com \
  --env GHOST_SMTP_PASSWORD=your_password \
  --env GHOST_SMTP_FROM_ADDRESS=ghost@blog.com \
  --network ghost-network \
  "${REPO_PATH}:${TAG}"
# Waiting for container to be configured successfuly and removed.
sleep 120
# Removing mysql container and ghost network
docker stop mysql-check
docker rm mysql-check
docker network rm ghost-network

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")
PORT=8080
CONTAINER_NAME="${PROJECT_NAME}"-ghost-1

# UI Test
# exec into container and check configuration
docker exec -i "${CONTAINER_NAME}" cat /opt/bitnami/ghost/config.production.json

# log for debugging
docker inspect "${CONTAINER_NAME}"

# Running selenium tests
"${SCRIPTPATH}"/../../common/selenium_tests/runner-dc.sh "${PROJECT_NAME}" "${PORT}" "${SCRIPTPATH}"/selenium_tests 2>&1
