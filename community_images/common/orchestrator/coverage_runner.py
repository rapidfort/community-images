""" Coverage runner module """

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
        # FIXME: add common_commands using container run separately


        image_name = self.config_dict.get("name")
        namespace_name = self._get_namespace(image_name)
        release_name = f"rf-{image_name}"
        cmd_params, image_tag_kv_list = self._prepare_cmd_params(namespace_name, release_name, command)

        for runtime in runtimes:
            for runtime_type, runtime_props in runtime.items():
                script = runtime_props.get("script")
                logging.info(f"Running runtime script for {runtime_type}: {script}")

                image_script_dir = os.path.abspath(
                    f"{self.script_dir}/../../{self.config_name}")
                script_path = os.path.join(image_script_dir, script)
                logging.info(f"Script abs path to execute: {script_path}")

                # call runner
                runtime_runner_map[runtime_type](
                    image_script_dir,
                    script_path,
                    runtime_props,
                    command,
                    cmd_params,
                    image_tag_kv_list,
                    namespace_name,
                    release_name
                )

    @staticmethod
    def _get_namespace(image_name, random_part_len=10):
        """ Creates a namespace with combination of image_name and randome string """
        letters = string.ascii_lowercase + string.digits
        random_letters = ''.join(random.choice(letters) for i in range(random_part_len))
        return f"{image_name}-{random_letters}"

    def _prepare_cmd_params(self, namespace_name, release_name, command):
        """ prepare command params and return cmd params, image_tag_list"""
        number_of_images = str(len(self.tag_mappings))
        cmd_params = [namespace_name, release_name, number_of_images]

        image_tag_list= []
        image_tag_kv_list = []
        for tag_mapping in self.tag_mappings:
            tag_details = tag_mapping.output_tag_details
            image_tag_key = tag_details.repo_path
            image_tag_list.append(image_tag_key)
            if command == Commands.STUB_COVERAGE:
                image_tag_value = tag_details.stub_tag
            elif command == Commands.HARDEN_COVERAGE:
                image_tag_value = tag_details.hardened_tag
            elif command == Commands.LATEST_COVERAGE:
                image_tag_value = "latest"
            image_tag_list.append(image_tag_value)
            image_tag_kv_list.append((image_tag_key, image_tag_value))
        cmd_params += image_tag_list
        logging.info(f"command params = {cmd_params}")
        return cmd_params, image_tag_kv_list

    @staticmethod
    def _k8s_runner(
        image_script_dir, script_path, runtime_props, command, cmd_params, image_tag_kv_list, namespace_name, release_name):
        """ Runtime for k8s runner """
        logging.info(f"k8s runner called for {script_path} {runtime_props} {command}")

        with K8sSetup(namespace_name, release_name, image_tag_kv_list, runtime_props, image_script_dir):
            if os.path.exists(script_path):
                subprocess.check_output([script_path] + cmd_params)

    @staticmethod
    def _docker_compose_runner(
        image_script_dir, script_path, runtime_props, command, cmd_params, image_tag_kv_list, namespace_name, release_name):
        """ Runtime for docker compose runner """
        logging.info(f"docker compose runner called for {script_path} {runtime_props} {command}")

        with DockerComposeSetup(namespace_name, release_name, image_tag_kv_list, runtime_props, image_script_dir):
            if os.path.exists(script_path):
                subprocess.check_output([script_path] + cmd_params)

    @staticmethod
    def _docker_runner(
        image_script_dir, script_path, runtime_props, command, cmd_params, image_tag_kv_list, namespace_name, release_name):
        """ Runtime for docker runner """
        logging.info(f"docker runner called for {script_path} {runtime_props} {command}")

        with DockerSetup(namespace_name, release_name, image_tag_kv_list, runtime_props, image_script_dir):
            if os.path.exists(script_path):
                subprocess.check_output([script_path] + cmd_params)
