#!/bin/bash

set -x
set -e

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

run_coverage()
{
    local NAMESPACE=$1
    shift
    local RELEASE_NAME=$1
    shift
    local NUMBER_OF_IMAGES=$1
    shift

    local IMAGE_TAG_ARRAY=( "$@" )

    for i in {1.."$NUMBER_OF_IMAGES"}
    do
        local IMAGE_REPOSITORY="${IMAGE_TAG_ARRAY[0]}"
        shift
        local TAG="${IMAGE_TAG_ARRAY[0]}"
        shift

        echo "Executing command commands in container: ${IMAGE_REPOSITORY}: ${TAG}"
    done
}

NAMESPACE="$1"
shift
RELEASE_NAME="$1"
shift
NUMBER_OF_IMAGES="$1"
shift

run_coverage "${NAMESPACE}" "${RELEASE_NAME}" "${NUMBER_OF_IMAGES}" "$@"
