#!/bin/bash

set -e
# set -x

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit ; pwd -P )"

pushd "${SCRIPTPATH}"

# Setup paths
ROOT_PATH=${SCRIPTPATH}/..
IMAGE_LST=${ROOT_PATH}/image.lst

IMAGE_TEMP_LST=${ROOT_PATH}/image.temp.lst
sort "${IMAGE_LST}" | grep ironbank > "${IMAGE_TEMP_LST}"

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
	yq -i ".${image_name}.search_tags += [\"${tag}\"]" "${REPO_SET_FILE}"

	## Populate image.yml(s) ##
	prev_tags=$(yq '.repo_sets[].*.input_base_tag' <<< "${image_yml}")
	
	is_matched=0
	for prev_tag in ${prev_tags}; do
		prev_tag_reg=${prev_tag//./\\.}
		prev_tag_reg=${prev_tag_reg//\*/\.*}
		tag_reg=${tag//./\\.}
		tag_reg=${tag_reg//\*/\.*}
		
		echo -e "\033[32mMatching [${prev_tag}] [${tag}] \033[0m"
		if [[ ${prev_tag} =~ ${tag_reg} || ${tag} =~ ${prev_tag_reg} ]]; then
			echo -e "\033[31mTag matched [${prev_tag//\n/,}] [${tag}] \033[0m"
			is_matched=1
			break
		fi
	done

	if [[ ${is_matched} == 0 ]]; then
		echo -e "\033[31mNo tag matched [${prev_tags}] [${tag}] \033[0m"
		repo_set=$(yq '.repo_sets[0]' <<< "${image_yml}" |  yq ".*.input_base_tag = \"${tag}\"" )
		REPO_SET="${repo_set}" yq -i eval '.repo_sets += env(REPO_SET)' "${ROOT_PATH}"/community_images/"${img_dir}"/image.yml
	fi

done < "${IMAGE_TEMP_LST}"

# Cleanup
rm "${IMAGE_TEMP_LST}"

popd