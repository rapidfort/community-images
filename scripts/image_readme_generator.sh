#!/bin/bash

# This script generates readme for image using readme.yml present in each directory
# master jinja2 tempalte exists at common/templates/image_readme.j2

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

pip install jinja-cli

while IFS="" read -r p || [ -n "$p" ]
do
  jinja -d community_images/"${p}"/readme.yml -f yaml community_images/common/templates/image_readme.j2 > community_images/"${p}"/README.md
done < "${SCRIPTPATH}"/../image.lst