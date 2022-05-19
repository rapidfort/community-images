#!/usr/bin/env bash

USERNAME=rapidfortbot
PASSWORD="figure_out"
ORGANIZATION="rapidfort"
IMAGE=$1
TAG=$2

login_data() {
cat <<EOF
{
  "username": "${USERNAME}",
  "password": "${PASSWORD}"
}
EOF
}

TOKEN=`curl -s -H "Content-Type: application/json" -X POST -d "$(login_data)" "https://hub.docker.com/v2/users/login/" | jq -r .token`

curl "https://hub.docker.com/v2/repositories/${ORGANIZATION}/${IMAGE}/tags/${TAG}/" \
-X DELETE \
-H "Authorization: JWT ${TOKEN}"