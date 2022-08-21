#!/bin/bash

set -x
set -e

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")

# run pytest
set +e #ignore test failures
docker-compose --env-file "${SCRIPTPATH}"/.env_hobby -f "${SCRIPTPATH}"/docker-compose.yml -p "${NAMESPACE}" run engine python -m pytest
set -e

# issue token
docker-compose --env-file "${SCRIPTPATH}"/.env_hobby -f "${SCRIPTPATH}"/docker-compose.yml -p "${NAMESPACE}" run engine python manage.py issue_invite_for_the_frontend --override