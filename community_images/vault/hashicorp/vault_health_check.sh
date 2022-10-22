#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/scripts/bash_helper.sh

NAMESPACE=$1
RELEASE_NAME=$2

with_backoff kubectl wait pods "${RELEASE_NAME}"-0 -n "${NAMESPACE}" \
    --for=condition=ready --timeout=20m