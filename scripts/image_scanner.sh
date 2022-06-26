#!/bin/bash

# This script goes through scan_image.lst and scans all images

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

input="${SCRIPTPATH}"/../scan_image.lst
while IFS= read -r image
do
  docker pull "$image":latest
  rfscan "$image":latest
done < "$input"
