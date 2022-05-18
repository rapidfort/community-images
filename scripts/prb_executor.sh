#!/usr/bin/bash

set -x
set -e
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

cat ${SCRIPTPATH}/image_list.txt | parallel "${SCRIPTPATH}/../community_images/{.}/run.sh"
