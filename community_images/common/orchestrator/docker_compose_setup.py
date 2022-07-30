""" Docker compose setup module """

import logging
import os
import time
from utils import Utils

class DockerComposeSetup:
    """ Docker compose setup context manager """
    def __init__(self, namespace_name, release_name, image_tag_list, runtime_props, image_script_dir):
        self.namespace_name = namespace_name
        self.release_name = release_name
        self.image_tag_list = image_tag_list
        self.runtime_props = runtime_props
        self.image_script_dir = image_script_dir
        self.script_dir = os.path.abspath(os.path.dirname( __file__ ))

    def __enter__(self):
        """ create a docker compose namespace and set it up for runner """
        # update image in docker-compose yml
        infile_path = f"{self.image_script_dir}/docker-compose.yml.base"
        outfile_path = f"{self.image_script_dir}/docker-compose.yml"

        search_str = "@IMAGE"
        replace_str = "${IMAGE_REPOSITORY}:${TAG}" #fixme
        Utils.replace_in_file(infile_path, outfile_path, search_str, replace_str)

        # install docker container
        env_file = f"{self.image_script_dir}/.env_hobby"

        cmd=f"docker-compose --env-file {env_file}"
        cmd+=f" -f {outfile_path} -p {self.namespace_name}"
        cmd+=f" up --build -d"
        subprocess.check_output(cmd.split())

        # sleep for wait time seconds
        time.sleep(30)

    def __exit__(self, type, value, traceback):
        """ delete docker compose namespace """
        # logs for tracking
        cmd=f"docker-compose -f {self.script_dir}/docker-compose.yml"
        cmd+=f" -p {self.namespace_name} logs"
        subprocess.check_output(cmd.split())

        # kill docker-compose setup container
        cmd=f"docker-compose -f {self.script_dir}/docker-compose.yml"
        cmd+=f" -p {self.namespace_name} down"
        subprocess.check_output(cmd.split())

        # clean up docker file
        os.remove(f"{self.script_dir}/docker-compose.yml")
