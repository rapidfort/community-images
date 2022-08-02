""" Docker compose setup module """

import logging
import os
import subprocess
import time

class DockerComposeSetup:
    """ Docker compose setup context manager """
    def __init__(self, namespace_name, release_name, image_tag_details, runtime_props, image_script_dir):
        self.namespace_name = namespace_name
        self.release_name = release_name
        self.image_tag_details = image_tag_details
        self.runtime_props = runtime_props
        self.image_script_dir = image_script_dir
        self.script_dir = os.path.abspath(os.path.dirname( __file__ ))
        self.docker_file = f"{self.script_dir}/docker-compose.yml"

    def __enter__(self):
        """ create a docker compose namespace and set it up for runner """

        docker_file = os.path.join(
            self.image_script_dir, self.runtime_props.get(
            "compose_file", "docker-compose.yml"))

        env_file = os.path.join(
            self.image_script_dir, self.runtime_props.get(
            "env_file", ".env"))
        logging.info(f"creating env file at: {env_file}")
        # generate or append to env file all image repo and tags
        with open(env_file, "a+", encoding="UTF-8") as env_fp:
            image_keys = self.runtime_props.get("image_keys", {})
            for repo_key, tag_details in self.image_tag_details.items():
                if repo_key in image_keys:
                    repository_key = image_keys[repo_key]["repository"]
                    repository_value = tag_details["repo_path"]

                    tag_key = image_keys[repo_key]["tag"]
                    tag_value = tag_details["tag"]
                    env_fp.write(f"{tag_key}={tag_value}\n")

        cmd="docker-compose"
        cmd+=f" --env-file {env_file}"
        cmd+=f" -f {self.docker_file} -p {self.namespace_name}"
        cmd+=" up --build -d"
        logging.info(f"cmd: {cmd}")
        subprocess.check_output(cmd.split())
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
