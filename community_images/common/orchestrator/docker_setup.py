""" Docker setup module """

import json
import logging
import os
import shutil
import subprocess
import time
from commands import Commands
from utils import Utils

class DockerSetup:
    """ Docker setup context manager """
    def __init__(
            self,
            namespace_name,
            release_name,
            image_tag_details,
            runtime_props,
            image_script_dir,
            command,
            daemon=True,
            entrypoint=None,
            exec_command=None):
        self.namespace_name = namespace_name
        self.release_name = release_name
        self.image_tag_details = image_tag_details
        self.runtime_props = runtime_props or {}
        self.image_script_dir = image_script_dir
        self.command = command
        self.script_dir = os.path.abspath(os.path.dirname( __file__ ))
        self.container_list = []
        self.cert_path = None
        self.daemon = daemon
        self.entrypoint = entrypoint
        self.exec_command = exec_command

    # pylint: disable=too-many-locals
    def __enter__(self):
        """ create a docker namespace and set it up for runner """
        # create network
        cmd=f"docker network create -d bridge {self.namespace_name}"
        subprocess.check_output(cmd.split())

        container_details = {}

        self.cert_path = Utils.generte_ssl_certs(
            self.image_script_dir, self.runtime_props.get("tls_certs", {}))

        common_volumes =  self.runtime_props.get("volumes", {})

        # create docker container
        for repo, tag_details in self.image_tag_details.items():
            repo_path = tag_details["repo_path"]
            tag = tag_details["tag"]
            container_detail = {}
            container_name = f"{repo}-{self.namespace_name}"
            # add container_name to image_tag_details
            self.image_tag_details[repo]["container_name"] = container_name

            image_runtime_props = self.runtime_props.get(repo, {})

            cmd="docker run --rm"
            cmd+=" -d" if self.daemon else " -i"
            cmd+=f" --network={self.namespace_name}"

            if self.entrypoint is not None:
                cmd+=f" --entrypoint {self.entrypoint}"

            if self.command == Commands.STUB_COVERAGE:
                cmd+=" --cap-add=SYS_PTRACE"

            env_file = os.path.join(
                self.image_script_dir, image_runtime_props.get(
                    "env_file", "docker.env"))

            if os.path.exists(env_file):
                cmd+=f" --env-file {env_file}"

            volumes = image_runtime_props.get("volumes", {})
            volumes.update(common_volumes)

            for src_mnt_rel_path, dst_mnt_path in volumes.items():
                src_mnt_abs_path = os.path.join(
                    self.image_script_dir, src_mnt_rel_path)

                if os.path.exists(src_mnt_abs_path):
                    cmd+=f" -v {src_mnt_abs_path}:{dst_mnt_path}"
                else:
                    logging.warning(f"mount path specified but dont exist {src_mnt_abs_path}")

            cmd+=f" --name {container_name}"
            cmd+=f" {repo_path}:{tag}"

            if self.exec_command is not None:
                cmd+=f" {self.exec_command}"

            logging.info(f"cmd: {cmd}")
            subprocess.check_output(cmd.split())

            container_detail["name"] = container_name
            self.container_list.append(container_name)
            container_details[repo] = container_detail

        if self.daemon:
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
        if self.daemon:
            for container in self.container_list:
                cmd=f"docker kill {container}"
                logging.info(f"cmd: {cmd}")
                subprocess.check_output(cmd.split())

        # delete network
        cmd=f"docker network rm {self.namespace_name}"
        subprocess.check_output(cmd.split())

        # remove cert dir
        if self.cert_path:
            shutil.rmtree(self.cert_path)
