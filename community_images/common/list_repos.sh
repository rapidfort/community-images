#!/bin/bash

# This script deletes a image tag from dockerhub repo

if [[ $# -ne 1 ]]; then
    echo "Usage:$0 <org>"
    exit 1
fi

ORGANIZATION=$1

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


login_data() {
cat <<EOF
{
  "username": "${USERNAME}",
  "password": "${PASSWORD}"
}
EOF
}

get_repos()
{
    TOKEN=$(curl -s -H "Content-Type: application/json" -X POST -d "$(login_data)" "https://hub.docker.com/v2/users/login/" | jq -r .token)
    paginated_repo_list=
    for p in {1..10} ; do
        prepo_list=$(curl -s -H "Authorization: JWT ${TOKEN}" \
        "https://hub.docker.com/v2/repositories/${ORGANIZATION}/?page_size=100&page=$p")

        paginated_repo_list+=$(echo "$prepo_list" | jq -r '.results|.[]|.name')
    done

    echo "$paginated_repo_list" | while read -r object; do
        echo "${ORGANIZATION}/$object"
    done
}

get_repos
