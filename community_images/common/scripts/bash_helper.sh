#!/bin/bash

set -x
set -e

# Retries a command a with backoff.
#
# The retry count is given by ATTEMPTS (default 10), the
# initial backoff timeout is given by TIMEOUT in seconds
# (default 5.)
#
# Successive backoffs double the timeout.
#
# Beware of set -e killing your whole script!
function with_backoff {
  local max_attempts="${ATTEMPTS-9}"
  local timeout="${TIMEOUT-5}"
  local attempt=0
  local exitCode=0

  while [[ "$attempt" < "$max_attempts" ]]
  do
    set +e
    "$@" 2>&1
    exitCode="$?"
    set -e

    if [[ "$exitCode" == 0 ]]
    then
      break
    fi

    echo "Failure! Retrying in $timeout.." 2>&1
    sleep "$timeout"
    attempt=$(( attempt + 1 ))
    timeout=$(( timeout * 2 ))
  done

  if [[ "$exitCode" != 0 ]]
  then
    echo "You've failed me for the last time! ($*)" 2>&1
  fi

  return "$exitCode"
}

function cleanup_certs()
{
    rm -rf "${SCRIPTPATH}"/certs
    mkdir -p "${SCRIPTPATH}"/certs
}

function create_certs()
{
    cleanup_certs

    openssl req -newkey rsa:4096 \
                -x509 \
                -sha256 \
                -days 3650 \
                -nodes \
                -out "${SCRIPTPATH}"/certs/server.crt \
                -keyout "${SCRIPTPATH}"/certs/server.key \
                -subj "/C=SI/ST=Ljubljana/L=Ljubljana/O=Security/OU=IT Department/CN=www.example.com"
}
