""" Coverage runner module """

import json
import logging
import os
import random
import string
from commands import Commands
from k8s_setup import K8sSetup
from docker_compose_setup import DockerComposeSetup
from docker_setup import DockerSetup
from utils import Utils


class CoverageRunner:
    """ Coverage Runner class """

    RUNTIME_TYPE_K8S = "k8s"
    RUNTIME_TYPE_DOCKER_COMPOSE = "docker_compose"
    RUNTIME_TYPE_DOCKER = "docker"

    def __init__(self, orchestrator, config_name, config_dict, repo_set_mappings):
        self.orchestrator = orchestrator
        self.config_name = config_name
        self.config_dict = config_dict
        self.repo_set_mappings = repo_set_mappings
        self.script_dir = os.path.abspath(os.path.dirname(__file__))

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
        for tag_mappings in self.repo_set_mappings:
            try:
                self.run_tag_mappings(command, tag_mappings)
            except Exception as exec:  # pylint:disable=broad-except
                logging.warning(
                    f"Coverage run {command} failed for {tag_mappings} due to {exec}")
                raise

    # pylint: disable = too-many-locals
    def run_tag_mappings(self, command, tag_mappings):
        """ Run tag mappings for command and tag mappings"""

        runtimes = self.config_dict.get("runtimes", [])

        runtime_runner_map = {
            self.RUNTIME_TYPE_K8S: self._k8s_runner,
            self.RUNTIME_TYPE_DOCKER_COMPOSE: self._docker_compose_runner,
            self.RUNTIME_TYPE_DOCKER: self._docker_runner,
        }

        image_name = self.config_dict.get("name")
        namespace_name = self._get_namespace(image_name) if self.orchestrator.namespace_name == "< n u l l >" else self.orchestrator.namespace_name
        release_name = f"rf-{image_name}"

        image_tag_details = self._prepare_image_tag_details(
            command, tag_mappings)

        if not image_tag_details:
            logging.info("Nothing to generate as image_tag_details is empty")
            return

        image_script_dir = os.path.abspath(
            f"{self.script_dir}/../../{self.config_name}")

        for runtime_props in runtimes:
            runtime_type = runtime_props.get("type")
            runtime_runner = runtime_runner_map[runtime_type]

            script = runtime_props.get("script")
            script_path = None
            if script:
                logging.info(
                    f"Running runtime script for {runtime_type}: {script}")
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

        needs_common_commands = self.config_dict.get("needs_common_commands", True)
        if needs_common_commands and command == Commands.STUB_COVERAGE:
            # add common commands
            self._common_command_runner(
                image_script_dir,
                image_tag_details,
                namespace_name,
                release_name,
                command
            )

        # Clearing Docker Volumes
        logging.info("Removing unused Docker Volumes")
        os.system('docker volume prune --force')

    @staticmethod
    def _get_namespace(image_name, random_part_len=10):
        """ Creates a namespace with combination of image_name and randome string """
        letters = string.ascii_lowercase + string.digits
        random_letters = ''.join(random.choice(letters)
                                 for i in range(random_part_len))
        return f"{image_name}-{random_letters}"

    def _prepare_image_tag_details(self, command, tag_mappings):
        """ Prepare image tag details for runner objects """
        image_tag_details = {}
        for tag_mapping in tag_mappings:
            if (tag_mapping.needs_generation
                or (not tag_mapping.needs_generation and
                    command == Commands.LATEST_COVERAGE)):

                tag_details = tag_mapping.output_tag_details

                image_tag_details[tag_details.repo] = {}

                image_tag_details[tag_details.repo]["repo_path"] = tag_details.repo_path
                if command == Commands.STUB_COVERAGE:
                    image_tag_value = tag_details.stub_tag
                elif command == Commands.HARDEN_COVERAGE:
                    # we only push original tag to registry
                    image_tag_value = tag_details.tag
                elif command == Commands.LATEST_COVERAGE:
                    version_tag_for_latest = (self.orchestrator.
                                                output_registry_helper.
                                                find_version_tag_for_rolling_tag(
                                                    tag_details.account,
                                                    tag_details.repo,
                                                    "latest"))
                    image_tag_value = version_tag_for_latest or "latest"

                image_tag_details[tag_details.repo]["tag"] = image_tag_value

        logging.info(f"Image tag list = {image_tag_details}")
        return image_tag_details

    @staticmethod
    def _dump_runner_to_json(
            image_script_dir,
            run_dict,
            file_name="run_param.json"):
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
            if script_path and os.path.exists(script_path):
                json_file_path = self._dump_runner_to_json(
                    image_script_dir, run_dict)
                Utils.run_cmd([script_path, json_file_path])
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
        logging.info(
            f"docker compose runner called for {script_path} {runtime_props}")

        with DockerComposeSetup(
                namespace_name,
                release_name,
                image_tag_details,
                runtime_props,
                image_script_dir,
                command) as run_dict:
            if script_path and os.path.exists(script_path):
                json_file_path = self._dump_runner_to_json(
                    image_script_dir, run_dict)
                Utils.run_cmd([script_path, json_file_path])
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
            if script_path and os.path.exists(script_path):
                json_file_path = self._dump_runner_to_json(
                    image_script_dir, run_dict)
                Utils.run_cmd([script_path, json_file_path])
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

        sciprt_path_parts = len(self.config_name.split("/"))
        common_commands_prefix = "../" * sciprt_path_parts
        common_command_rel_path = common_commands_prefix + \
            "common/tests/common_commands.sh"

        logging.info(f"calculated common path={common_command_rel_path}")

        runtime_props = {
            "daemon": False,
            "entrypoint": "/tmp/common_commands.sh",
            "volumes": {
                common_command_rel_path: "/tmp/common_commands.sh"}}

        with DockerSetup(
                namespace_name,
                release_name,
                image_tag_details,
                runtime_props,
                image_script_dir,
                command) as run_dict:
            logging.info(f"Calling common commands with params: {run_dict}")
