""" Docker setup module """

import json
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
        self.env_file = os.path.join(
            self.image_script_dir, self.runtime_props.get(
            "env_file", "docker.env"))
        self.container_list = []

    def __enter__(self):
        """ create a docker namespace and set it up for runner """
        # create network
        cmd=f"docker network create -d bridge {self.namespace_name}"
        subprocess.check_output(cmd.split())

        container_details = {}

        # create docker container
        for repo, tag_details in self.image_tag_details.items():
            repo_path = tag_details["repo_path"]
            tag = tag_details["tag"]
            container_detail = {}
            container_name = f"{repo}-{self.namespace_name}"
            # add container_name to image_tag_details
            self.image_tag_details[repo]["container_name"] = container_name

            cmd=f"docker run --rm -d --network={self.namespace_name}"

            if self.command == Commands.STUB_COVERAGE:
                cmd+=" --cap-add=SYS_PTRACE"

            if os.path.exists(self.env_file):
                cmd+=f" --env-file {self.env_file}"

            cmd+=f" --name {container_name}"
            cmd+=f" {repo_path}:{tag}"
            logging.info(f"cmd: {cmd}")
            subprocess.check_output(cmd.split())

            container_detail["name"] = container_name
            self.container_list.append(container_name)
            container_details[repo] = container_detail

        # sleep for few seconds
        time.sleep(self.runtime_props.get("wait_time_sec", 30))

        container_details = self._get_docker_ips(container_details)

        return {
            "namespace_name": self.namespace_name,
            "release_name": self.release_name,
            "image_tag_details": self.image_tag_details,
            "network_name": self.namespace_name,
            "container_details": container_details
        }

    def _get_docker_ips(self, container_details):
        # add docker ips for all containers
        for container_detail in container_details.values():
            container_name = container_detail["name"]
            cmd=f"docker inspect {container_name}"
            docker_inspect_json = subprocess.check_output(cmd.split())
            docker_inspect_dict = json.loads(docker_inspect_json)
            if len(docker_inspect_dict):
                docker_inspect0 = docker_inspect_dict[0]
                network_settings = docker_inspect0.get("NetworkSettings", {})
                networks = network_settings.get("Networks", {})
                net_details = networks.get(self.namespace_name, {})
                ip_address = net_details.get("IPAddress")
                if ip_address:
                    container_detail["ip_address"] = ip_address
        return container_details

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
