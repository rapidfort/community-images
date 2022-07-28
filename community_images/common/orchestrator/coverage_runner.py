""" Coverage runner module """

import logging
import os

# pylint:disable=too-few-public-methods
class CoverageRunner:
    """ Coverage Runner class """

    RUNTIME_TYPE_K8S = "k8s"
    RUNTIME_TYPE_DOCKER_COMPOSE = "docker_compose"
    RUNTIME_TYPE_DOCKER = "docker"

    def __init__(self, config_name, config_dict):
        self.config_name = config_name
        self.config_dict = config_dict

    def run(self):
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
                runtime_runner_map[runtime_type](script_path, runtime_props)

    # pylint:disable=no-self-use
    def _k8s_runner(self, script_path, runtime_props):
        """ Runtime for k8s runner """
        logging.info(f"k8s runner called for {script_path} {runtime_props}")

    # pylint:disable=no-self-use
    def _docker_compose_runner(self, script_path, runtime_props):
        """ Runtime for docker compose runner """
        logging.info(f"k8s runner called for {script_path} {runtime_props}")

    # pylint:disable=no-self-use
    def _docker_runner(self, script_path, runtime_props):
        """ Runtime for docker runner """
        logging.info(f"k8s runner called for {script_path} {runtime_props}")
