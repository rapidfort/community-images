#!/bin/bash

# This script generates readme for image using image.yml present in each directory
# master jinja2 tempalte exists at common/templates/image_readme.j2

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

pip install jinja-cli PyYAML

gen_image_files()
{
  while IFS="" read -r p || [ -n "$p" ]
  do
    jinja -d community_images/"${p}"/image.yml \
      -f yaml "${SCRIPTPATH}"/../community_images/common/templates/image_readme.j2 > "${SCRIPTPATH}"/../community_images/"${p}"/README.md

    # shellcheck disable=SC2001
    RUN_FILE_NAME=$(echo "$p" | sed 's|/|_|g')
    jinja -d community_images/"${p}"/image.yml \
      -f yaml "${SCRIPTPATH}"/../community_images/common/templates/image_run.yml.j2 > "${SCRIPTPATH}"/../.github/workflows/"${RUN_FILE_NAME}".yml
  done < "${SCRIPTPATH}"/../image.lst
}

gen_image_files()
{
  while IFS="" read -r p || [ -n "$p" ]
  do
    # shellcheck disable=SC2001
    RUN_FILE_NAME=$(echo "$p" | sed 's|/|_|g')
    jinja -d community_images/"${p}"/image.yml \
      -f yaml "${SCRIPTPATH}"/../community_images/common/templates/image_run_v2.yml.j2 > "${SCRIPTPATH}"/../.github/workflows/"${RUN_FILE_NAME}"_v2.yml
  done < "${SCRIPTPATH}"/../image_v2.lst
}
echo "Generating main readme"

gen_main_readme()
{
  rm -f "${SCRIPTPATH}"/../image_list.yml
  python3 "${SCRIPTPATH}"/gen_image_list.py "${SCRIPTPATH}"/

  jinja -d "${SCRIPTPATH}"/../image_list.yml \
    -f yaml "${SCRIPTPATH}"/../community_images/common/templates/main_readme.j2 > "${SCRIPTPATH}"/../README.md

  jinja -d "${SCRIPTPATH}"/../image_list.yml \
    -f yaml "${SCRIPTPATH}"/../community_images/common/templates/monitor.yml.j2 > "${SCRIPTPATH}"/../.github/workflows/monitor.yml

  jinja -d "${SCRIPTPATH}"/../image_list.yml \
    -f yaml "${SCRIPTPATH}"/../community_images/common/templates/readme_updater.yml.j2 > "${SCRIPTPATH}"/../.github/workflows/readme_updater.yml

  rm -f "${SCRIPTPATH}"/../image_list.yml
}

main()
{
  gen_main_readme
  gen_image_files
}

main
