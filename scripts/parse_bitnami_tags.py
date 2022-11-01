# This script fetches bitnami repo locally and
# creates a dict of all bitnami assets which we support
# for these assets, we can generate search string for pulling image
# we can also generate docker_links array for documentation

import logging
import shutil
import subprocess
import sys
import tempfile


class BitnamiTagsHelper:
    def __init__(self):
        self.clone_path = tempfile.mkdtemp()

    def clone_bitnami_repo(self):
        """ clones the latest bitnami repo locally """
        cmd = f"git clone --depth 1 git@github.com:bitnami/containers.git {self.clone_path}"
        cmd_array = cmd.split()
        output_pipe = subprocess.check_output(cmd_array, stderr=sys.stdout)
        logging.info("%s", output_pipe.decode("utf-8"))
        return self.clone_path

    def get_common_assets(self):
        """ Check all the assets we have in common with bitnami """
        return []

    def read_asset(self):
        """ For a given asset read branch/distro/tags-info and create a dict """
        return {}

    def generate_docker_links(self):
        """ Use given asset dict generate docker_links array for documentation """
        return []

    def generate_search_tags(self):
        """ Use given asset dict generate search tags """
        return []


def main():
    bth = BitnamiTagsHelper()
    clone_path = bth.clone_bitnami_repo()
    print(clone_path)

    assets = bth.get_common_assets()
    for asset in assets:
        asset_dict = bth.read_asset(asset)
        docker_links = bth.generate_docker_links(asset_dict)
        search_tags = bth.generate_search_tags(asset_dict)

    shutil.rmtree(clone_path)

if __name__ == "__main__":
    main()
