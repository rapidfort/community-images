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
with_backoff()
{
  local max_attempts="${ATTEMPTS-9}"
  local timeout="${TIMEOUT-5}"
  local attempt=0
  local exitCode=0

  while [[ "$attempt" -lt "$max_attempts" ]]
  do
    set +e
    "$@"
    exitCode="$?"
    set -e

    if [[ "$exitCode" == 0 ]]
    then
      break
    fi

    echo "Failure! Retrying in $timeout.." 1>&2
    sleep "$timeout"
    attempt=$(( attempt + 1 ))
    timeout=$(( timeout * 2 ))
  done

  if [[ "$exitCode" != 0 ]]
  then
    echo "You've failed me for the last time! ($*)" 1>&2
  fi

  return "$exitCode"
}

probe_process_running_inside_container_timeout()
{
    # How to use:
    # probe_process_running_inside_container_timeout "container_name" "process_name" 30

    local container_name="${1}"
    if [ -z "${container_name}" ]; then
        echo "${container_name}" required. skipping wait
        return 1
    fi

    local process_name="${2}"
    if [ -z "${process_name}" ]; then
        echo "${process_name}" required. skipping wait
        return 1
    fi

    local timeout="${3:-30}" # default max is 30 secs
    local max_attempts
    local attempt=1
    local itr_timeout=1
    local found=false

    max_attempts=$((timeout/itr_timeout))

    set +e

    while [ $attempt -le $max_attempts ]; do
        echo "Attempt $attempt/$max_attempts: Checking for $process_name in container $container_name ..."

        if docker top "$container_name" | grep -q "$process_name"; then
            found=true
            break
        else
            echo "Process $process_name is not running. Retrying in $itr_timeout seconds..."
            attempt=$((attempt + 1))
            sleep 1
        fi
    done

    set -e

    if $found; then
        echo "$process_name is running inside container $container_name"
        return 0
    else
        echo "$process_name is NOT running inside container $container_name"
        return 1
    fi
}

probe_endpoint_health()
{
    # How to use:
    # probe_endpoint_health "http://localhost:8080/health" 30

    local url="${1}"
    local timeout="${2:-30}"
    if [ -z "${url}" ]; then
        echo "${url}" required. skipping wait
        return 1
    fi

    local max_attempts
    local attempt=1
    local itr_timeout=1
    local success=false
    local http_code

    max_attempts=$((timeout/itr_timeout))

    set +e

    while [ $attempt -le $max_attempts ]; do

        echo "Attempt $attempt/$max_attempts: Checking URL $url..."
        http_code=$(curl --head --location --connect-timeout 5 --write-out "%{http_code}" --silent --output /dev/null "${url}")

        if [ "$http_code" -eq 200 ]; then
            success=true
            break
        else
            echo "Failed: HTTP $url status code $http_code. Retrying in $itr_timeout seconds..."
            attempt=$((attempt + 1))
            sleep $itr_timeout
        fi
    done


    if $success; then
        echo "Success ${url} - with status $http_code"
        return 0
    else
        echo "Error ${url} - failed with status $http_code"
        return 1
    fi
}

