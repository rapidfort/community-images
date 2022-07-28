""" Coverage runner module """

import logging
import os
import subprocess
from commands import Commands


# pylint:disable=too-few-public-methods
class CoverageRunner:
    """ Coverage Runner class """

    RUNTIME_TYPE_K8S = "k8s"
    RUNTIME_TYPE_DOCKER_COMPOSE = "docker_compose"
    RUNTIME_TYPE_DOCKER = "docker"

    def __init__(self, config_name, config_dict, tag_mappings):
        self.config_name = config_name
        self.config_dict = config_dict
        self.tag_mappings = tag_mappings

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

        for runtime in runtimes:
            for runtime_type, runtime_props in runtime.items():
                script = runtime_props.get("script")
                logging.info(f"Running runtime script for {runtime_type}: {script}")

                script_dir = os.path.abspath(os.path.dirname( __file__ ))
                script_path = os.path.abspath(
                    os.path.join(f"{script_dir}/../../{self.config_name}/{script}"))
                logging.info(f"Script abs path to execute: {script_path}")

                # call runner
                runtime_runner_map[runtime_type](script_path, runtime_props, command)

    # pylint:disable=no-self-use
    def _k8s_runner(self, script_path, runtime_props, command):
        """ Runtime for k8s runner """
        logging.info(f"k8s runner called for {script_path} {runtime_props} {command}")

        namespace = "test"
        number_of_images = str(len(self.tag_mappings))
        cmd_array = [script_path, namespace, number_of_images]

        for tag_mapping in self.tag_mappings:
            tag_details = tag_mapping.output_tag_details
            cmd_array.append(tag_details.repo_path)
            if command == Commands.STUB_COVERAGE:
                cmd_array.append(tag_details.stub_tag)
            elif command == Commands.HARDEN_COVERAGE:
                cmd_array.append(tag_details.hardened_tag)
            elif command == Commands.LATEST_COVERAGE:
                cmd_array.append("latest")

        subprocess.check_output(cmd_array)

    # pylint:disable=no-self-use
    def _docker_compose_runner(self, script_path, runtime_props, command):
        """ Runtime for docker compose runner """
        logging.info(f"k8s runner called for {script_path} {runtime_props} {command}")

    # pylint:disable=no-self-use
    def _docker_runner(self, script_path, runtime_props, command):
        """ Runtime for docker runner """
        logging.info(f"k8s runner called for {script_path} {runtime_props} {command}")
