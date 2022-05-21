#!/bin/bash

set -x
set -e

REDIS_PASSWORD=$1
shift
HELM_RELEASE=$1
shift
REDIS_TEST_FILE=$1
shift
TLS_PREFILX=( "$@" )

input="${REDIS_TEST_FILE}"
while IFS= read -r line
do
    # shellcheck disable=SC2086
    REDISCLI_AUTH="${REDIS_PASSWORD}" redis-cli -h "${HELM_RELEASE}" "${TLS_PREFILX[@]}" -c $line
done < "$input"
