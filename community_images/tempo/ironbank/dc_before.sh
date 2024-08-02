#!/bin/bash

set -ex

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "JSON = $JSON"

mkdir -p "${SCRIPTPATH}/log"
LOG=${SCRIPTPATH}/log/myjob.log

for ((i = 0; i < 100; i++)); do
  # shellcheck disable=SC2129
  echo "$(date +'%Y-%m-%d %H:%M:%S') status something happend at $i" >> "${LOG}"
  echo "$(date +'%Y-%m-%d %H:%M:%S') started something happend at $i" >> "${LOG}"
  echo "$(date +'%Y-%m-%d %H:%M:%S') running something happend at $i" >> "${LOG}"
  echo "$(date +'%Y-%m-%d %H:%M:%S') killed something happend at $i" >> "${LOG}"
  echo "$(date +'%Y-%m-%d %H:%M:%S') stopped something happend at $i" >> "${LOG}"
done
