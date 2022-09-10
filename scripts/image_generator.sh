#!/bin/bash

# This script generates readme for image using image.yml present in each directory
# master jinja2 tempalte exists at common/templates/image_readme.j2

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

pip install jinja-cli PyYAML

gen_image_readme()
{
  while IFS="" read -r p || [ -n "$p" ]
  do
    jinja -d community_images/"${p}"/image.yml \
      -f yaml "${SCRIPTPATH}"/../community_images/common/templates/image_readme.j2 > "${SCRIPTPATH}"/../community_images/"${p}"/README.md

  done < "${SCRIPTPATH}"/../image.lst
}


gen_main_readme()
{
  echo "Generating main readme"
  rm -f "${SCRIPTPATH}"/../image_list.yml
  python3 "${SCRIPTPATH}"/gen_image_list.py "${SCRIPTPATH}"/../image.lst

  jinja -d "${SCRIPTPATH}"/../image_list.yml \
    -f yaml "${SCRIPTPATH}"/../community_images/common/templates/main_readme.j2 > "${SCRIPTPATH}"/../README.md

  jinja -d "${SCRIPTPATH}"/../image_list.yml \
    -f yaml "${SCRIPTPATH}"/../community_images/common/templates/monitor.yml.j2 > "${SCRIPTPATH}"/../.github/workflows/monitor.yml

  jinja -d "${SCRIPTPATH}"/../image_list.yml \
    -f yaml "${SCRIPTPATH}"/../community_images/common/templates/readme_updater.yml.j2 > "${SCRIPTPATH}"/../.github/workflows/readme_updater.yml

  jinja -d "${SCRIPTPATH}"/../image_list.yml \
    -f yaml "${SCRIPTPATH}"/../community_images/common/templates/frontrow.csv.j2 > "${SCRIPTPATH}"/../frontrow.csv

  jinja -d "${SCRIPTPATH}"/../community_images/common/templates/image_yml_params.yml \
    -f yaml "${SCRIPTPATH}"/../community_images/common/templates/image_yml_readme.j2 > "${SCRIPTPATH}"/../image_yml.md

  rm -f "${SCRIPTPATH}"/../image_list.yml
}

gen_new_image_actions()
{
  rm -f "${SCRIPTPATH}"/../image_list.yml
  python3 "${SCRIPTPATH}"/gen_image_list.py "${SCRIPTPATH}"/../builder.lst

  jinja -d "${SCRIPTPATH}"/../image_list.yml \
    -f yaml "${SCRIPTPATH}"/../community_images/common/templates/image_run_v3.yml.j2 > "${SCRIPTPATH}"/../.github/workflows/image_run_v3.yml

  rm -f "${SCRIPTPATH}"/../image_list.yml
}

del_image_variants()
{
  declare -a image_variants=( "airflow_airflow-scheduler_bitnami" "airflow_airflow-worker_bitnami" )

  for image_variant in "${image_variants[@]}"; do
    rm -f "${SCRIPTPATH}"/../.github/workflows/"${image_variant}".yml
  done
}

main()
{
  gen_main_readme
  gen_image_readme
  # gen_image_files
  # gen_image_files2
  gen_new_image_actions
  del_image_variants
}

main
