#!/bin/bash

# This script deletes a image tag from dockerhub repo

if [[ $# -ne 3 ]]; then
    echo "Usage:$0 <image> <tag>"
    exit 1
fi

IMAGE=$1
TAG=$2

if [[ -z "$DOCKERHUB_USERNAME" ]]; then
    echo "Must provide DOCKERHUB_USERNAME in env"
    exit 1
fi

if [[ -z "$DOCKERHUB_PASSWORD" ]]; then
    echo "Must provide DOCKERHUB_PASSWORD in env"
    exit 1
fi

USERNAME=${DOCKERHUB_USERNAME}
PASSWORD=${DOCKERHUB_PASSWORD}
ORGANIZATION="rapidfort"


login_data() {
cat <<EOF
{
  "username": "${USERNAME}",
  "password": "${PASSWORD}"
}
EOF
}

delete_tag()
{
    TOKEN=$(curl -s -H "Content-Type: application/json" -X POST -d "$(login_data)" "https://hub.docker.com/v2/users/login/" | jq -r .token)

    curl "https://hub.docker.com/v2/repositories/${ORGANIZATION}/${IMAGE}/tags/${TAG}/" \
    -X DELETE \
    -H "Authorization: JWT ${TOKEN}"
}

delete_tag