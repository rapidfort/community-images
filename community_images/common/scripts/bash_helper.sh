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
