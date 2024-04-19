#!/bin/bash

set -x
set -e

NAMESPACE=$1
RELEASE_NAME=$2

kubectl wait deployment "${RELEASE_NAME}"-0 -n "${NAMESPACE}" \
    --for=condition=Available=True --timeout=20m

