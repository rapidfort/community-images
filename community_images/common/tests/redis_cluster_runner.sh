#!/bin/bash

set -x
set -e

REDIS_PASSWORD=$1
HELM_RELEASE=$2
REDIS_TEST_FILE=$3

input=${REDIS_TEST_FILE}
while IFS= read -r line
do
    REDISCLI_AUTH=$REDIS_PASSWORD redis-cli -h ${HELM_RELEASE} -c $line
done < "$input"
