""" Docker compose setup module """

import logging
import os
import subprocess
import time
from utils import Utils

class DockerComposeSetup:
    """ Docker compose setup context manager """
    def __init__(self, namespace_name, release_name, image_tag_kv_list, runtime_props, image_script_dir):
        self.namespace_name = namespace_name
        self.release_name = release_name
        self.image_tag_kv_list = image_tag_kv_list
        self.runtime_props = runtime_props
        self.image_script_dir = image_script_dir
        self.script_dir = os.path.abspath(os.path.dirname( __file__ ))
        self.docker_file = f"{self.script_dir}/docker-compose.yml"

    def __enter__(self):
        """ create a docker compose namespace and set it up for runner """
        # update image in docker-compose yml
        base_docker_file = os.path.join(
            self.image_script_dir, self.runtime_props.get(
            "base_file", "docker-compose.yml.base"))

        search_replace_dict = {}
        search_str = "@IMAGE"
        replace_str = f"{self.image_tag_kv_list[0][0]}:{self.image_tag_kv_list[0][1]}" # FIXME: support multiple image
        search_replace_dict[search_str] = replace_str
        Utils.replace_in_file(
            base_docker_file,
            self.docker_file,
            search_replace_dict
        )

        # install docker container
        env_file = self.runtime_props.get("env_file")

        cmd="docker-compose"
        if env_file:
            cmd+=" --env-file self.image_script_dir/env_file"

        cmd+=f" -f {self.docker_file} -p {self.namespace_name}"
        cmd+=" up --build -d"
        subprocess.check_output(cmd.split())
        logging.info(f"cmd: {cmd}")
        # sleep for wait time seconds
        time.sleep(self.runtime_props.get("wait_time_sec", 30))

    def __exit__(self, type, value, traceback):
        """ delete docker compose namespace """
        # logs for tracking
        cmd=f"docker-compose -f {self.docker_file}"
        cmd+=f" -p {self.namespace_name} logs"
        subprocess.check_output(cmd.split())

        # kill docker-compose setup container
        cmd=f"docker-compose -f {self.docker_file}"
        cmd+=f" -p {self.namespace_name} down"
        subprocess.check_output(cmd.split())

        # clean up docker file
        os.remove(self.docker_file)
