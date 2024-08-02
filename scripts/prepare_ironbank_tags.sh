#!/bin/bash

set -e
# set -x

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit ; pwd -P )"

pushd "${SCRIPTPATH}"

# Setup paths
ROOT_PATH=${SCRIPTPATH}/..
IMAGE_LST=${ROOT_PATH}/image.lst

IMAGE_TEMP_LST=${ROOT_PATH}/image.temp.lst
# There is an issue from ironbank side regarding the vault image. Ironbank has incorrectly marked the latest vault image version as "9.1" instead of "1.7".
# Our automated scripts pull information from ironbank and get the incorrect tag. 
# Until the issue from ironbank is fixed we are excluding vault/ironbank for any automation script.
sort "${IMAGE_LST}" | grep ironbank | grep -v vault/ironbank > "${IMAGE_TEMP_LST}"

REPO_SET_FILE=${ROOT_PATH}/ironbank_tags.yml
echo "" > "${REPO_SET_FILE}"

# shellcheck disable=SC2162
while read img_dir; do
	## Populate ironbank_tags.yml ##
	image_yml=$(cat "${ROOT_PATH}/community_images/${img_dir}/image.yml")
	image_name=$(yq '.name' <<< "${image_yml}")
	gitlab_uri=$(yq '.source_image_readme' <<< "${image_yml}" | grep ".*/-/" -o)raw/development/hardening_manifest.yaml

	echo ""
	echo "${image_name} : ${gitlab_uri}"

	yq -i "del(.${image_name})" "${REPO_SET_FILE}"

	tag=$(wget -O - -q "${gitlab_uri}" | yq '.tags[]' | grep -v '^latest$' | sed -e 's/\"//g' -e 's/\.[^.]*$/./g' | sort -V | tail -n 1)
	echo -e "\033[34mtag > ${tag}\033[0m"

	if [[ ${tag} == "" ]]; then
		continue
	fi

	yq -i ".${image_name}.search_tags = [\"${tag}\"]" "${REPO_SET_FILE}"

	new_set=$(yq ".repo_sets[0]" "${ROOT_PATH}/community_images/${img_dir}/image.yml" | yq ".*.input_base_tag = \"${tag}\"") yq -i eval ".repo_sets = [ env(new_set) ]" "${ROOT_PATH}/community_images/${img_dir}/image.yml"

done < "${IMAGE_TEMP_LST}"

# Cleanup
rm "${IMAGE_TEMP_LST}"

popd
