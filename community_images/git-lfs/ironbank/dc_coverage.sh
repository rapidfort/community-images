#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")
CONTAINER_NAME=${PROJECT_NAME}-git-lfs-1
# Checks the Git version
docker exec -i "${CONTAINER_NAME}" git --version
# Checks the Git LFS version
docker exec -i "${CONTAINER_NAME}" git-lfs --version
# help on git-lfs command
docker exec -i "${CONTAINER_NAME}" git lfs help
# help on git commands
docker exec -i "${CONTAINER_NAME}" git help
# Initializes a new Git repository inside the Docker container
docker exec -i "${CONTAINER_NAME}" git init
# Sets up Git LFS to track large binary files with the .bin extension.
docker exec -i "${CONTAINER_NAME}" git lfs track "*.psd"
docker exec -i "${CONTAINER_NAME}" git config user.email "rf@test.com"
docker exec -i "${CONTAINER_NAME}" git config user.name "test"
# adding to attribute file
docker exec -i "${CONTAINER_NAME}" git add .gitattributes
docker exec -i "${CONTAINER_NAME}" git commit -m "track *.psd files using Git LFS"
# Generates a large binary file named large_file.bin with 100 MB of random data.
docker exec -i "${CONTAINER_NAME}" bash -c 'dd if=/dev/urandom of=large_file.psd bs=1M count=100'
# Adds the large binary file to the Git repository, utilizing Git LFS for tracking.
docker exec -i "${CONTAINER_NAME}" git add large_file.psd
# displays helpful information about your Git repository
docker exec -i "${CONTAINER_NAME}" git lfs env
docker exec -i "${CONTAINER_NAME}" git commit -m "add bin"
# Lists the files tracked by Git LFS in the repository.
docker exec -i "${CONTAINER_NAME}" git lfs ls-files
docker exec -i "${CONTAINER_NAME}" ls
