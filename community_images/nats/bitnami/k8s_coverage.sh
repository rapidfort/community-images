#!/bin/bash

set -x
set -e

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/coverage.sh

run_coverage()
{
    local NAMESPACE=$1
    shift
    local HELM_RELEASE=$1
    shift
    shift # we dont need number of images, hence shift

    local IMAGE_TAG_ARRAY=( "$@" )

    local IMAGE_REPOSITORY="${IMAGE_TAG_ARRAY[0]}"
    local TAG="${IMAGE_TAG_ARRAY[1]}"
    
    echo "Testing $REPOSITORY"

    # run coverage script
    test_nats "${NAMESPACE}" "${HELM_RELEASE}"
}

NAMESPACE="$1"
shift
HELM_RELEASE="$1"
shift
NUMBER_OF_IMAGES="$1"
shift

run_coverage "${NAMESPACE}" "${HELM_RELEASE}" "${NUMBER_OF_IMAGES}" "$@"
