""" Docker setup module """

import json
import logging
import os
import subprocess
import shutil
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
            command):
        self.namespace_name = namespace_name
        self.release_name = release_name
        self.image_tag_details = image_tag_details
        self.runtime_props = runtime_props or {}
        self.image_script_dir = image_script_dir
        self.command = command
        self.script_dir = os.path.abspath(os.path.dirname(__file__))
        self.container_details = {}
        self.cert_path = None

    # pylint: disable=too-many-locals,too-many-branches,too-many-statements
    def __enter__(self):
        """ create a docker namespace and set it up for runner """
        # create network
        cmd = f"docker network create -d bridge {self.namespace_name}"
        Utils.run_cmd(cmd.split())

        self.cert_path = Utils.generate_ssl_certs(
            self.image_script_dir, self.runtime_props.get("tls_certs", {}))

        common_daemon = self.runtime_props.get("daemon", True)
        common_entrypoint = self.runtime_props.get("entrypoint")
        common_volumes = self.runtime_props.get("volumes", {})
        common_environment = self.runtime_props.get("environment", {})
        common_user = self.runtime_props.get("user", {})

        # create docker container
        for repo, tag_details in self.image_tag_details.items():
            repo_path = tag_details["repo_path"]
            tag = tag_details["tag"]
            container_detail = {}
            container_name = f"{repo}-{self.namespace_name}"
            # add container_name to image_tag_details
            self.image_tag_details[repo]["container_name"] = container_name

            image_runtime_props = self.runtime_props.get(repo, {})

            if "daemon" not in image_runtime_props:
                daemon = common_daemon
            else:
                daemon = image_runtime_props.get("daemon", True)

            if "entrypoint" not in image_runtime_props:
                entrypoint = common_entrypoint
            else:
                entrypoint = image_runtime_props.get("entrypoint")

            exec_command = image_runtime_props.get("exec_command")

            cmd = "docker run --rm"
            cmd += " -d" if daemon else " -i"
            cmd += f" --network={self.namespace_name}"

            if entrypoint is not None:
                cmd += f" --entrypoint {entrypoint}"
            if common_user is not None:
                cmd += f" --user {common_user}"
            if self.command == Commands.STUB_COVERAGE:
                cmd += " --cap-add=SYS_PTRACE"

            env_file = os.path.join(
                self.image_script_dir, image_runtime_props.get(
                    "env_file", "docker.env"))

            if os.path.exists(env_file):
                cmd += f" --env-file {env_file}"

            environment = image_runtime_props.get("environment", {})
            environment.update(common_environment)

            for key, val in environment.items():
                cmd += f" -e {key}={val}"

            ports = image_runtime_props.get("ports", [])

            for port in ports:
                cmd += f" -p {port}"

            volumes = image_runtime_props.get("volumes", {})
            volumes.update(common_volumes)

            for src_mnt_rel_path, dst_mnt_path in volumes.items():
                src_mnt_abs_path = os.path.join(
                    self.image_script_dir, src_mnt_rel_path)

                if os.path.exists(src_mnt_abs_path):
                    cmd += f" -v {src_mnt_abs_path}:{dst_mnt_path}"
                else:
                    logging.warning(
                        f"mount path specified but dont exist {src_mnt_abs_path}")

            cmd += f" --name {container_name}"
            cmd += f" {repo_path}:{tag}"

            if exec_command is not None:
                cmd += f" {exec_command}"

            logging.info(f"cmd: {cmd}")
            Utils.run_cmd(cmd.split())

            container_detail["daemon"] = daemon
            container_detail["name"] = container_name
            self.container_details[repo] = container_detail

        # sleep for few seconds
        time.sleep(self.runtime_props.get("wait_time_sec", 30))
        self.container_details = self._get_docker_ips(self.container_details)

        return {
            "namespace_name": self.namespace_name,
            "release_name": self.release_name,
            "image_tag_details": self.image_tag_details,
            "network_name": self.namespace_name,
            "container_details": self.container_details,
            "image_script_dir": self.image_script_dir,
            "runtime_props": self.runtime_props
        }

    def _get_docker_ips(self, container_details):
        # add docker ips for all containers
        for container_detail in container_details.values():
            container_name = container_detail["name"]
            daemon = container_detail["daemon"]
            if not daemon:
                continue

            cmd = f"docker inspect {container_name}"
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
        for container_detail in self.container_details.values():
            daemon = container_detail["daemon"]
            name = container_detail["name"]
            if not daemon:
                continue
            cmd = f"docker kill {name}"
            logging.info(f"cmd: {cmd}")
            Utils.run_cmd(cmd.split())

        # delete network
        cmd = f"docker network rm {self.namespace_name}"
        Utils.run_cmd(cmd.split())

        # remove cert dir
        if self.cert_path:
            shutil.rmtree(self.cert_path)
