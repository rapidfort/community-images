#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"
NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")

ANSIBLE_CONTAINER_NAME="${NAMESPACE}"-ansible-1
UBUNTU_CONTAINER_NAME="${NAMESPACE}"-ubuntu_host-1

UBUNTU_HOST_IP=${docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "${UBUNTU_CONTAINER_NAME}"}

docker exec -i -u root "${UBUNTU_CONTAINER_NAME}" apt-get update
docker exec -i -u root "${UBUNTU_CONTAINER_NAME}" apt-get install -y openssh-server
docker exec -i -u root "${UBUNTU_CONTAINER_NAME}" sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
docker exec -i -u root "${UBUNTU_CONTAINER_NAME}" sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
docker exec -i -u root "${UBUNTU_CONTAINER_NAME}" service ssh restart
docker exec -i -u root "${UBUNTU_CONTAINER_NAME}" bash -c 'mkdir -p ~/.ssh && chmod 700 ~/.ssh'

docker exec -i -u root "${ANSIBLE_CONTAINER_NAME}" ssh-keygen -t rsa -f /root/.ssh/id_rsa -N ""
SSH_KEYS=${docker exec -u root ${ANSIBLE_CONTAINER_NAME} cat /root/.ssh/id_rsa.pub}







