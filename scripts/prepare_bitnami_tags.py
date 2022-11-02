"""
This script fetches bitnami repo locally and
creates a dict of all bitnami assets which we support
for these assets, we can generate search string for pulling image
we can also generate docker_links array for documentation
"""

import logging
import os
import shutil
import subprocess
import sys
import tempfile
import yaml

class BitnamiTagsHelper:
    """ Bitnami tags helper """
    def __init__(self):
        self.clone_path = tempfile.mkdtemp()
        self.script_path = os.path.dirname(os.path.abspath(__file__))
        self.image_list_file = "image.lst"

    def clone_bitnami_repo(self):
        """ clones the latest bitnami repo locally """
        cmd = f"git clone --depth 1 git@github.com:bitnami/containers.git {self.clone_path}"
        cmd_array = cmd.split()
        output_pipe = subprocess.check_output(cmd_array, stderr=sys.stdout)
        logging.info("%s", output_pipe.decode("utf-8"))
        return self.clone_path

    def get_common_assets(self):
        """ Check all the assets we have in common with bitnami """
        bcontainer_list = []

        image_lst_path = os.path.join(self.script_path, "..", self.image_list_file)
        with open(image_lst_path, "r", encoding="utf8") as stream:
            for image_path in stream.readlines():
                image_path_parts = image_path.split("/")

                if image_path_parts and "bitnami" in image_path_parts[-1]:
                    bcontainer_name = image_path_parts[-2]
                    bcontainer_list.append(bcontainer_name)

        return bcontainer_list

    @staticmethod
    def _get_dirs(dirname):
        """ git dirs in a directory """
        dirfiles = os.listdir(dirname)
        fullpaths = map(lambda name: os.path.join(dirname, name), dirfiles)
        dirs = []
        for file in fullpaths:
            if os.path.isdir(file):
                dirs.append(file)
        return dirs

    @staticmethod
    def _get_abs_name(dirname):
        """ get abs name """
        return dirname.split("/")[-1]

    @staticmethod
    def _read_tags_info(tags_info_path):
        """ Read tags-info.yml """
        try:
            with open(tags_info_path, "r", encoding="utf8") as yml_stream:
                tags_dict = yaml.safe_load(yml_stream)
                return tags_dict.get("rolling-tags", [])
        except yaml.YAMLError as exc:
            logging.error(exc)
        return []

    def read_asset(self, asset):
        """ For a given asset read branch/distro/tags-info and create a dict """
        asset_dict = {}
        logging.info("Reading asset %s", asset)
        asset_dir = os.path.join(self.clone_path, "bitnami", asset)
        branch_dirs = self._get_dirs(asset_dir)
        for branch_dir in branch_dirs:
            distro_dirs = self._get_dirs(branch_dir)
            for distro_dir in distro_dirs:
                tag_file = os.path.join(distro_dir, "tags-info.yaml")
                if os.path.exists(tag_file):
                    tag_array = self._read_tags_info(tag_file)
                    tag_version = tag_array[2]
                    asset_dict[tag_version] = {}
                    asset_dict[tag_version]["branch"] = self._get_abs_name(branch_dir)
                    asset_dict[tag_version]["distro"] = self._get_abs_name(distro_dir)
                    asset_dict[tag_version]["tag_array"] = tag_array
        return asset_dict

    def generate_outputs(self, asset, asset_dict):
        """ Use given asset dict generate docker_links and search_tags array for documentation
        Sample input
        12.12.0 {'branch': '12', 'distro': 'debian-11', 'tag_array': ['12', '12-debian-11', '12.12.0']}
        Sample output
        - "[`12`, `12-debian-11`, `12.12.0`, `12.12.0-debian-11-r0` (12/debian-11/Dockerfile)](https://github.com/bitnami/containers/tree/main/bitnami/postgresql/12/debian-11/Dockerfile)"
        """
        docker_links = []
        search_tags = []
        for version, version_dict in asset_dict.items():
            tag_array = version_dict["tag_array"]
            branch = version_dict["branch"]
            version = version_dict["tag_array"][2]
            distro = version_dict["distro"]
            search_tag = f"{version}-{distro}-r"
            docker_link = f"{branch}/{distro}/Dockerfile"
            docker_link_url = f"https://github.com/bitnami/containers/tree/main/bitnami/{asset}/{branch}/{distro}/Dockerfile"
            docker_link_line = f"[`{tag_array[0]}`, `{tag_array[1]}`, `{tag_array[2]}`, `{search_tag}` ({docker_link})]({docker_link_url})"
            docker_links.append(docker_link_line)
            search_tags.append(search_tag)
        return sorted(search_tags, reverse=True), sorted(docker_links, reverse=True)

    def dump_bitnami_tags(self, tags_dict):
        """ dump bitnami tags to yml format """
        out_yml_path = os.path.join(self.script_path, "..", "bitnami_tags.yml")
        with open(out_yml_path, "w", encoding="utf8") as outfile:
            yaml.dump(tags_dict, outfile, default_flow_style=False)


def main():
    """ main function """
    bth = BitnamiTagsHelper()
    clone_path = bth.clone_bitnami_repo()

    tags_dict = {}
    assets = bth.get_common_assets()
    for asset in assets:
        asset_dict = bth.read_asset(asset)
        tags_dict[asset] = {}
        search_tags, docker_links = bth.generate_outputs(asset, asset_dict)
        tags_dict[asset]["search_tags"] = search_tags
        tags_dict[asset]["docker_links"] = docker_links

    shutil.rmtree(clone_path)
    bth.dump_bitnami_tags(tags_dict)

if __name__ == "__main__":
    main()
