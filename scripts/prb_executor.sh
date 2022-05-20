#!/bin/bash

# This script runs all Pull Request tests in parallel

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

< "${SCRIPTPATH}"/../image.lst parallel -j10 --halt soon,fail=1 "${SCRIPTPATH}/../community_images/{.}/run.sh"

< "${SCRIPTPATH}"/../image.lst parallel -j10 --halt soon,fail=1 "${SCRIPTPATH}/../community_images/{.}/functional_test.sh"


# prune containers
docker image prune -a -f

# prune volumes
docker volume prune -f
