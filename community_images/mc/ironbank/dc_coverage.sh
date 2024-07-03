#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")
CONTAINER_NAME=${PROJECT_NAME}-minio-client-1

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

sleep 10

# docker exec "${CONTAINER_NAME}" mc alias set myminio http://mc-minio-1:9000 minio minio123
#bucket-creation
docker exec "${CONTAINER_NAME}"  mc mb myminio/test-bucket

docker exec "${CONTAINER_NAME}" mc ls myminio/test-bucket
# List all buckets
docker exec "${CONTAINER_NAME}" mc ls myminio
# List all users
docker exec "${CONTAINER_NAME}" mc admin user list myminio
# Mirror a directory to Minio
docker exec "${CONTAINER_NAME}" mc mirror /tmp myminio/test-bucket
# List all groups
docker exec "${CONTAINER_NAME}" mc admin group list myminio

docker exec "${CONTAINER_NAME}" mc admin policy list myminio
#sql check
docker exec "${CONTAINER_NAME}" mc sql --help
docker exec "${CONTAINER_NAME}" mc -version
docker exec "${CONTAINER_NAME}" mc ls --versions
#check
docker exec "${CONTAINER_NAME}" mc ping myminio --count 1
# Remove the bucket
docker exec "${CONTAINER_NAME}" mc rb --force myminio/test-bucket
