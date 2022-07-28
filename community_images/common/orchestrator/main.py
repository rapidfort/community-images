""" Orchestrator for Community Images """

import argparse
from enum import Enum
import logging
import os

import docker
from stub import StubGenerator
from coverage_runner import CoverageRunner
from registry_helper import RegistryHelperFactory
from tag_manager import TagManager
import yaml

class Commands(Enum):
    """Enum for commands"""
    STUB = "stub"
    STUB_COVERAGE = "stub_coverage"
    HARDEN = "harden"
    HARDEN_COVERAGE = "harden_coverage"
    LATEST_COVERAGE = "latest_coverage"

    def __str__(self):
        return self.value.lower()


# pylint:disable=too-few-public-methods
class Orchestrator:
    """ Orchestrator class """
    def __init__(self, args):
        """ Orchestrator initialization """
        self.args = args
        self.config_dict = self._load_config()
        self.docker_client = docker.from_env()
        self.publish = args.publish
        self.config_name = self.args.config
        self.input_registry_helper, self.output_registry_helper = self._auth_registries()

    def _load_config(self) -> dict:
        """load config file"""
        script_dir = os.path.abspath(os.path.dirname( __file__ ))
        config_path = os.path.join(f"{script_dir}/../../{self.args.config}/image.yml")
        with open(config_path, encoding="UTF-8") as config_fp:
            config_dict = yaml.load(config_fp, Loader=yaml.FullLoader)
            logging.info(f"config_dict={config_dict}")
            return config_dict

    def run(self) -> None:
        """run commands for orchestrator"""
        command = self.args.command

        tag_manager = TagManager(self)

        if command == Commands.STUB:
            stub = StubGenerator(
                self.config_name,
                self.config_dict,
                self.docker_client,
                tag_manager.tag_mappings
            )
            stub.generate()
        elif command in [ Commands.STUB_COVERAGE,
                Commands.HARDEN_COVERAGE,
                Commands.LATEST_COVERAGE]:
            coverage_runner = CoverageRunner(self.config_name, self.config_dict)
            coverage_runner.run()

    def _auth_registries(self):
        """ Authenticate to registries
        Input schema

        input_registry:
            registry: docker.io
            account: bitnami
        output_registry:
            registry: docker.io
            account: rapidfort
        """
        input_registry_url = self.config_dict.get("input_registry", {}).get("registry")
        output_registry_url = self.config_dict.get("output_registry", {}).get("registry")

        input_registry_helper = RegistryHelperFactory.get_registry_helper(
            self.docker_client, input_registry_url)

        output_registry_helper = RegistryHelperFactory.get_registry_helper(
            self.docker_client, output_registry_url)

        # authenticate to input and output registries
        input_registry_helper.auth()
        output_registry_helper.auth()

        return input_registry_helper, input_registry_helper

def main():
    """main function"""
    parser = argparse.ArgumentParser()
    parser.add_argument("command", type=Commands, choices=list(Commands))
    parser.add_argument("config", type=str, help="point to image config in yaml formt")
    parser.add_argument("--publish", action="store_true", help="publish image")
    parser.add_argument(
        "--no-publish", dest="publish",
        action="store_false", help="dont publish image")
    parser.set_defaults(publish=False)
    parser.add_argument("--loglevel", type=str, default="info", help="debug, info, warning, error")
    args = parser.parse_args()

    numeric_level = getattr(logging, args.loglevel.upper(), None)
    if not isinstance(numeric_level, int):
        raise ValueError(f"Invalid log level: {args.loglevel}")

    logging.basicConfig(level=numeric_level,
        format= "[%(asctime)s] {%(pathname)s:%(lineno)d} %(levelname)s - %(message)s",
        datefmt="%H:%M:%S")

    logging.info(f"{args.command}, {args.config}")
    orchestrator = Orchestrator(args)
    orchestrator.run()


if __name__ == "__main__":
    main()
