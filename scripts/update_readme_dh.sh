#!/bin/bash

set -x
set -e

# This script creates dockerhub specific README file.
# The idea is to have sepearate UTM tracking for github vs dockerhub

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

FILE_LIST=$(find "${SCRIPTPATH}"/../community_images/ -type f -name "README.md")

for f in ${FILE_LIST}
do
 sed 's/utm_source=github/utm_source=dockerhub/g' "$f" > "$f".dockerhub
done
