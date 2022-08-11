""" Coverage runner module """

import json
import logging
import os
import random
import string
import subprocess
from commands import Commands
from k8s_setup import K8sSetup
from docker_compose_setup import DockerComposeSetup
from docker_setup import DockerSetup
class CoverageRunner:
    """ Coverage Runner class """

    RUNTIME_TYPE_K8S = "k8s"
    RUNTIME_TYPE_DOCKER_COMPOSE = "docker_compose"
    RUNTIME_TYPE_DOCKER = "docker"

    def __init__(self, config_name, config_dict, tag_mappings):
        self.config_name = config_name
        self.config_dict = config_dict
        self.tag_mappings = tag_mappings
        self.script_dir = os.path.abspath(os.path.dirname( __file__ ))

    def run(self, command):
        """ Runs coverage tests
        runtimes:
        - k8s:
            script: k8s_coverage.sh
        - docker_compose:
            script: dc_coverage.sh
        - docker:
            script: docker_coverage.sh
        """
        runtimes = self.config_dict.get("runtimes", [])

        runtime_runner_map = {
            self.RUNTIME_TYPE_K8S: self._k8s_runner,
            self.RUNTIME_TYPE_DOCKER_COMPOSE: self._docker_compose_runner,
            self.RUNTIME_TYPE_DOCKER: self._docker_runner,
        }

        image_name = self.config_dict.get("name")
        namespace_name = self._get_namespace(image_name)
        release_name = f"rf-{image_name}"
        image_tag_list = self._prepare_image_tag_list(command)

        if not image_tag_list:
            logging.info("Nothing to generate as image_tag_list is empty")
            return

        image_script_dir = os.path.abspath(
                f"{self.script_dir}/../../{self.config_name}")

        for image_tag_details in image_tag_list:
            for runtime_props in runtimes:
                runtime_type = runtime_props.get("type")
                runtime_runner = runtime_runner_map[runtime_type]

                script = runtime_props.get("script")
                logging.info(f"Running runtime script for {runtime_type}: {script}")

                script_path = os.path.join(image_script_dir, script)
                logging.info(f"Script abs path to execute: {script_path}")

                # call runner
                runtime_runner(
                    image_script_dir,
                    script_path,
                    runtime_props,
                    image_tag_details,
                    namespace_name,
                    release_name,
                    command
                )

            if command == Commands.STUB_COVERAGE:
                # add common commands
                self._common_command_runner(
                        image_script_dir,
                        image_tag_details,
                        namespace_name,
                        release_name,
                        command
                    )

    @staticmethod
    def _get_namespace(image_name, random_part_len=10):
        """ Creates a namespace with combination of image_name and randome string """
        letters = string.ascii_lowercase + string.digits
        random_letters = ''.join(random.choice(letters) for i in range(random_part_len))
        return f"{image_name}-{random_letters}"

    def _prepare_image_tag_list(self, command):
        """ Prepare image tag list for runner objects """

        image_tag_list = []
        for tag_mapping in self.tag_mappings:
            if (tag_mapping.needs_generation
                or (not tag_mapping.needs_generation and
                command == Commands.LATEST_COVERAGE)):

                image_tag_details = {}
                tag_details = tag_mapping.output_tag_details

                image_tag_details[tag_details.repo] = {}

                image_tag_details[tag_details.repo]["repo_path"] = tag_details.repo_path
                if command == Commands.STUB_COVERAGE:
                    image_tag_value = tag_details.stub_tag
                elif command == Commands.HARDEN_COVERAGE:
                    # we only push original tag to registry
                    image_tag_value = tag_details.tag
                elif command == Commands.LATEST_COVERAGE:
                    image_tag_value = "latest"

                image_tag_details[tag_details.repo]["tag"] = image_tag_value
                image_tag_list.append(image_tag_details)

        logging.info(f"Image tag list = {image_tag_list}")
        return image_tag_list

    @staticmethod
    def _dump_runner_to_json(image_script_dir, run_dict, file_name="run_param.json"):
        file_path = os.path.abspath(os.path.join(image_script_dir, file_name))
        with open(file_path, 'w', encoding="UTF-8") as json_fp:
            json.dump(run_dict, json_fp)
            return file_path

        return None

    def _k8s_runner(
            self,
            image_script_dir,
            script_path,
            runtime_props,
            image_tag_details,
            namespace_name,
            release_name,
            command):
        """ Runtime for k8s runner """
        logging.info(f"k8s runner called for {script_path} {runtime_props}")

        with K8sSetup(
                    namespace_name,
                    release_name,
                    image_tag_details,
                    runtime_props,
                    image_script_dir,
                    command
                ) as run_dict:
            if os.path.exists(script_path):
                json_file_path = self._dump_runner_to_json(image_script_dir, run_dict)
                subprocess.check_output([script_path, json_file_path])
                os.remove(json_file_path)

    def _docker_compose_runner(
            self,
            image_script_dir,
            script_path,
            runtime_props,
            image_tag_details,
            namespace_name,
            release_name,
            command):
        """ Runtime for docker compose runner """
        logging.info(f"docker compose runner called for {script_path} {runtime_props}")

        with DockerComposeSetup(
                namespace_name,
                release_name,
                image_tag_details,
                runtime_props,
                image_script_dir,
                command) as run_dict:
            if os.path.exists(script_path):
                json_file_path = self._dump_runner_to_json(image_script_dir, run_dict)
                subprocess.check_output([script_path, json_file_path])
                os.remove(json_file_path)

    def _docker_runner(
            self,
            image_script_dir,
            script_path,
            runtime_props,
            image_tag_details,
            namespace_name,
            release_name,
            command):
        """ Runtime for docker runner """
        logging.info(f"docker runner called for {script_path} {runtime_props}")

        with DockerSetup(
                namespace_name,
                release_name,
                image_tag_details,
                runtime_props,
                image_script_dir,
                command) as run_dict:
            if os.path.exists(script_path):
                json_file_path = self._dump_runner_to_json(image_script_dir, run_dict)
                subprocess.check_output([script_path, json_file_path])
                os.remove(json_file_path)


    def _common_command_runner(
            self,
            image_script_dir,
            image_tag_details,
            namespace_name,
            release_name,
            command):
        """ Common commands runner """
        logging.info("common command runner called")

        runtime_props = {"volumes":{"../../common/tests/common_commands.sh": "/tmp/common_commands.sh"}}

        with DockerSetup(
                namespace_name,
                release_name,
                image_tag_details,
                runtime_props,
                image_script_dir,
                command,
                False,
                "/tmp/common_commands.sh") as run_dict:
            logging.info(f"Calling common commands with params: {run_dict}")
