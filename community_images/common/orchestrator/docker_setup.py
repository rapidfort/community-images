""" Docker setup module """

import logging
import os
import subprocess
import time
from commands import Commands

class DockerSetup:
    """ Docker setup context manager """
    def __init__(
            self,
            namespace_name,
            release_name,
            image_tag_details,
            runtime_props,
            image_script_dir,
            command):
        self.namespace_name = namespace_name
        self.release_name = release_name
        self.image_tag_details = image_tag_details
        self.runtime_props = runtime_props or {}
        self.image_script_dir = image_script_dir
        self.command = command
        self.script_dir = os.path.abspath(os.path.dirname( __file__ ))
        self.container_list = []

    def __enter__(self):
        """ create a docker namespace and set it up for runner """
        # create network
        cmd=f"docker network create -d bridge {self.namespace_name}"
        subprocess.check_output(cmd.split())

        # create docker container
        for repo, tag_details in self.image_tag_details.items():
            repo_path = tag_details["repo_path"]
            tag = tag_details["tag"]
            container_name = f"{repo}-{self.namespace_name}"
            # add container_name to image_tag_details
            self.image_tag_details[repo]["container_name"] = container_name

            cmd=f"docker run --rm -d --network={self.namespace_name}"

            if self.command == Commands.STUB_COVERAGE:
                cmd+=" --cap-add=SYS_PTRACE"

            cmd+=f" --name {container_name}"
            cmd+=f" {repo_path}:{tag}"
            logging.info(f"cmd: {cmd}")
            subprocess.check_output(cmd.split())

            self.container_list.append(container_name)

        # sleep for few seconds
        time.sleep(self.runtime_props.get("wait_time_sec", 30))

        return {
            "namespace_name": self.namespace_name,
            "release_name": self.release_name,
            "image_tag_details": self.image_tag_details,
            "network_name": self.namespace_name
        }

    def __exit__(self, type, value, traceback):
        """ delete docker namespace """
        # clean up docker container
        for container in self.container_list:
            cmd=f"docker kill {container}"
            logging.info(f"cmd: {cmd}")
            subprocess.check_output(cmd.split())

        # delete network
        cmd=f"docker network rm {self.namespace_name}"
        subprocess.check_output(cmd.split())
