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
while IFS="" read -r p || [ -n "$p" ]
do
    REDISCLI_AUTH="${REDIS_PASSWORD}" redis-cli -h "${HELM_RELEASE}" "${TLS_PREFILX[@]}" -c "${p}"
done < "$input"
