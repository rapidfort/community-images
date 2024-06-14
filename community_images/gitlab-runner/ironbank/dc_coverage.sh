#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/scripts/bash_helper.sh

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

NAMESPACE_NAME=$(jq -r '.namespace_name' < "$JSON_PARAMS")

GITLAB_RUNNER_CONTAINER_NAME="${NAMESPACE_NAME}-gitlab-runner-1"
DEBIAN_SSH_CONTAINER_NAME="${NAMESPACE_NAME}-debian-ssh-1"

# Wait until GitLab WebUI is ready.
sleep 60

while ! (curl -s http://localhost:61780/ | grep "<html><body>You are being")
do
  echo "$(date +'%H:%M:%S') | Gitlab web server not up"
  sleep 2
done

echo "$(date +'%H:%M:%S') | Gitlab web server up and ready"

# Append id_rsa.pub generated to authorized_keys in debian-ssh docker container
docker exec -i "${DEBIAN_SSH_CONTAINER_NAME}" \
  bash -c "cat >> /root/.ssh/authorized_keys" < "${SCRIPTPATH}/id_rsa.pub"

# Populate `known_hosts` file
docker exec -i "${GITLAB_RUNNER_CONTAINER_NAME}" \
  ssh -o StrictHostKeyChecking=no root@debian-ssh -i /root/id_rsa exit

# Link data of SSH of `root` user with `gitlab-runner` user
docker exec -i "${GITLAB_RUNNER_CONTAINER_NAME}" \
  ln -s /root/.ssh /home/gitlab-runner/.ssh

(
  # Wait for selenium boot up
  sleep 30

  # Busy wait the creation of file containing runner registeration token on python-chromedriver
  echo "$(date +'%H:%M:%S') | Waiting for creation of runner on UI"
  while ! (docker exec -i python-chromedriver ls /usr/workspace/selenium_tests/runner_registeration_token_1 > /dev/null 2>&1); do
    echo "$(date +'%H:%M:%S') | Waiting for runner registeration token on UI"
    sleep 2
  done

  echo "$(date +'%H:%M:%S') | File with runner registeration token found [runner_registeration_token_1]"
  
  # Fetch the runner registeration token
  REGISTERATION_TOKEN=$(docker exec -i python-chromedriver cat /usr/workspace/selenium_tests/runner_registeration_token_1)

  # Create an SSH executer to execute jobs on debian-ssh container via SSH 
  docker exec -i "${GITLAB_RUNNER_CONTAINER_NAME}" \
    gitlab-runner register --non-interactive \
      --url http://gitlab:61780 \
      --token "${REGISTERATION_TOKEN}" \
      --executor ssh \
      --ssh-user root \
      --ssh-host debian-ssh \
      --ssh-port 22 \
      --ssh-identity-file /root/id_rsa

  echo "$(date +'%H:%M:%S') | Runner Registered with ${REGISTERATION_TOKEN}"
   
) &
export RUNNER_REGISTER_PID=$!

# Trap SIGINT and SIGTERM to prevent runner registeration process to run 
#   in background of terminal while manual testing
trap 'kill ${RUNNER_REGISTER_PID}' SIGINT
trap 'kill ${RUNNER_REGISTER_PID}' SIGTERM

# Get gitlab port and initial login passowrd to access web interface
PORT=61780
GITLAB_ROOT_PASSWORD=$(sudo grep 'Password:' "${SCRIPTPATH}/config/initial_root_password" | awk '{print $2}')

# Initiating Selenium tests
("${SCRIPTPATH}"/../../common/selenium_tests/runner-dc.sh "${GITLAB_ROOT_PASSWORD}" "${PORT}" "${SCRIPTPATH}"/selenium_tests 2>&1 ) >&2

# Kill the runner registeration process if runner_registeration takes time or selenium fails.
kill "${RUNNER_REGISTER_PID}" || true
