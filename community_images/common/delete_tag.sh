#!/usr/bin/env bash

USERNAME=$0
PASSWORD=$1
ORGANIZATION="rapidfort"
IMAGE=$2
TAG=$3

login_data() {
cat <<EOF
{
  "username": "$USERNAME",
  "password": "$PASSWORD"
}
EOF
}

TOKEN=`curl -s -H "Content-Type: application/json" -X POST -d "$(login_data)" "https://hub.docker.com/v2/users/login/" | jq -r .token`

curl "https://hub.docker.com/v2/${ORGANIZATION}/${IMAGE}/manifests/${TAG}" \
-X DELETE \
-H "Authorization: JWT ${TOKEN}"