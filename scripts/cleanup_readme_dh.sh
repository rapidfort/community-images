#!/bin/bash

set -x
set -e

# This script deletes all temp README.md.dockerhub created by update_readme_dh.sh script

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

FILE_LIST=$(find "${SCRIPTPATH}"/../community_images/ -type f -name "README.md.dockerhub")

for f in ${FILE_LIST}
do
 rm -rf "$f"
done
