#!/bin/bash

REDIS_PASSWORD=$1
HELM_RELEASE=$2
REDIS_TEST_FILE=$3

CMD_LINE="REDISCLI_AUTH=\"${REDIS_PASSWORD}\" redis-cli -h ${HELM_RELEASE} -c"

input=${REDIS_TEST_FILE}
while IFS= read -r line
do
  ${CMD_LINE} "$line"
done < "$input"
