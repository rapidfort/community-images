""" Docker compose setup module """

import logging
import os
import shutil
import subprocess
import time
from utils import Utils


class DockerComposeSetup:
    """ Docker compose setup context manager """

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
        self.docker_file = os.path.join(
            self.image_script_dir, self.runtime_props.get(
                "compose_file", "docker-compose.yml"))
        self.source_env_file = os.path.join(
            self.image_script_dir, self.runtime_props.get(
                "env_file", "docker.env"))
        self.temp_env_file = f"{self.source_env_file}.temp"
        self.cert_path = None

    def _generate_env_file(self):

        if os.path.exists(self.source_env_file):
            shutil.copyfile(self.source_env_file, self.temp_env_file)

        logging.info(f"creating env file at: {self.temp_env_file}")
        # generate or append to env file all image repo and tags
        with open(self.temp_env_file, "a+", encoding="UTF-8") as env_fp:
            image_keys = self.runtime_props.get("image_keys", {})
            for repo_key, tag_details in self.image_tag_details.items():
                if repo_key in image_keys:
                    repository_key = image_keys[repo_key]["repository"]
                    repository_value = tag_details["repo_path"]
                    env_fp.write(f"{repository_key}={repository_value}\n")
                    logging.info(f"adding {repository_key}={repository_value}")

                    tag_key = image_keys[repo_key]["tag"]
                    tag_value = tag_details["tag"]
                    env_fp.write(f"{tag_key}={tag_value}\n")
                    logging.info(f"adding {tag_key}={tag_value}")

    def __enter__(self):
        """ create a docker compose namespace and set it up for runner """

        self._generate_env_file()

        self.cert_path = Utils.generate_ssl_certs(
            self.image_script_dir, self.runtime_props.get("tls_certs", {}))

        cmd = "docker-compose"
        cmd += f" --env-file {self.temp_env_file}"
        cmd += f" -f {self.docker_file} -p {self.namespace_name}"
        cmd += " up --build -d"
        logging.info(f"cmd: {cmd}")
        Utils.run_cmd(cmd.split())
        # sleep for wait time seconds
        time.sleep(self.runtime_props.get("wait_time_sec", 30))

        # dump logs
        cmd = "docker-compose"
        cmd += f" --env-file {self.temp_env_file}"
        cmd += f" -f {self.docker_file} -p {self.namespace_name}"
        cmd += " logs"
        logging.info(f"cmd: {cmd}")
        Utils.run_cmd(cmd.split())

        return {
            "namespace_name": self.namespace_name,
            "release_name": self.release_name,
            "image_tag_details": self.image_tag_details,
            "project_name": self.namespace_name,
            "network_name": f"{self.namespace_name}_default",
            "image_script_dir": self.image_script_dir,
            "runtime_props": self.runtime_props
        }

    def __exit__(self, type, value, traceback):
        """ delete docker compose namespace """
        # logs for tracking
        cmd = f"docker-compose --env-file {self.temp_env_file} -f {self.docker_file}"
        cmd += f" -p {self.namespace_name} logs"
        Utils.run_cmd(cmd.split())

        # kill docker-compose setup container
        try:
            cmd = f"docker-compose --env-file {self.temp_env_file} -f {self.docker_file}"
            cmd += f" -p {self.namespace_name} down --timeout 60"
            Utils.run_cmd(cmd.split())
        except subprocess.CalledProcessError as excp:
            logging.info(f"docker-compose down failed due to {excp}")

        # remove temp env file
        os.remove(self.temp_env_file)

        # # remove cert dir
        # if self.cert_path:
        #     shutil.rmtree(self.cert_path)
