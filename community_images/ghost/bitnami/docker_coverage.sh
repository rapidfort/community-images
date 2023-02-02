#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker coverage = $JSON"

NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")

# get docker host ip
REPO_PATH=$(jq -r '.image_tag_details."ghost".repo_path' < "$JSON_PARAMS")
TAG=$(jq -r '.image_tag_details."ghost".tag' < "$JSON_PARAMS")

# run docker
# create network and mysql db
docker network create ghost-network
docker run -d --name mysql-check \
  --env ALLOW_EMPTY_PASSWORD=yes \
  --env MYSQL_USER=bn_ghost \
  --env MYSQL_PASSWORD=bitnami \
  --env MYSQL_DATABASE=bitnami_ghost \
  --network ghost-network \
  --volume /path/to/mysql-persistence:/bitnami/mysql \
  rapidfort/mysql:latest

# Create ghost container
docker run --rm -i --cap-add=SYS_PTRACE --name="${NAMESPACE}"-"$(date +%s)" -d\
  -p 8080:8080 -p 8443:8443 \
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
sleep 40

# Removing mysql container and ghost network
docker stop mysql-check
docker rm mysql-check
docker network rm ghost-network