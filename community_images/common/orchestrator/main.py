""" Orchestrator for Community Images """

import argparse
import logging
import os

import docker
from harden_generator import HardenGenerator
from stub_generator import StubGenerator
from coverage_runner import CoverageRunner
from registry_helper import RegistryHelperFactory
from tag_manager import TagManager
from commands import Commands
import yaml


class Orchestrator:
    """ Orchestrator class """

    def __init__(self, args):
        """ Orchestrator initialization """
        self.args = args
        self.config_dict = self._load_config()
        self.docker_client = docker.from_env()
        self.publish = args.publish
        self.namespace_name = args.namespace_name
        self.force_publish = args.force_publish
        self.config_name = self.args.config.strip("/")
        self.input_registry_helper, self.output_registry_helper = self._auth_registries()

    def _load_config(self) -> dict:
        """load config file"""
        script_dir = os.path.abspath(os.path.dirname(__file__))
        config_path = os.path.join(
            f"{script_dir}/../../{self.args.config}/image.yml")
        with open(config_path, encoding="UTF-8") as config_fp:
            config_dict = yaml.load(config_fp, Loader=yaml.FullLoader)
            logging.info(f"config_dict={config_dict}")
            return config_dict

    def run(self) -> None:
        """run commands for orchestrator"""
        command = self.args.command
        publish = self.args.publish
        tag_manager = TagManager(self)

        if command == Commands.STUB:
            StubGenerator(
                self.config_name,
                self.config_dict,
                self.docker_client,
                tag_manager.repo_set_mappings
            ).generate()
        elif command in [Commands.STUB_COVERAGE,
                         Commands.HARDEN_COVERAGE,
                         Commands.LATEST_COVERAGE]:
            CoverageRunner(
                self,
                self.config_name,
                self.config_dict,
                tag_manager.repo_set_mappings
            ).run(command)
        elif command == Commands.HARDEN:
            HardenGenerator(
                self,
                self.config_name,
                self.config_dict,
                self.docker_client,
                tag_manager.repo_set_mappings
            ).generate(publish)
        elif command == Commands.HOURLY_RUN:
            self._hourly_run(tag_manager)

    def _hourly_run(self, tag_manager):

        publish = self.args.publish

        StubGenerator(
            self.config_name,
            self.config_dict,
            self.docker_client,
            tag_manager.repo_set_mappings
        ).generate()

        CoverageRunner(
            self,
            self.config_name,
            self.config_dict,
            tag_manager.repo_set_mappings
        ).run(Commands.STUB_COVERAGE)

        HardenGenerator(
            self,
            self.config_name,
            self.config_dict,
            self.docker_client,
            tag_manager.repo_set_mappings
        ).generate(publish)

        if publish:
            CoverageRunner(
                self,
                self.config_name,
                self.config_dict,
                tag_manager.repo_set_mappings
            ).run(Commands.HARDEN_COVERAGE)

            CoverageRunner(
                self,
                self.config_name,
                self.config_dict,
                tag_manager.repo_set_mappings
            ).run(Commands.LATEST_COVERAGE)

    def _auth_registries(self):
        """ Authenticate to registries
        Input schema

        input_registry:
            registry: docker.io
            account: bitnami
        """
        input_registry_url = self.config_dict.get(
            "input_registry", {}).get("registry")
        output_registry_url = os.environ.get(
            "RAPIDFORT_OUTPUT_REGISTRY", "docker.io")

        input_registry_helper = RegistryHelperFactory.get_registry_helper(
            self.docker_client, input_registry_url)

        output_registry_helper = RegistryHelperFactory.get_registry_helper(
            self.docker_client, output_registry_url)

        # authenticate to input and output registries
        if not input_registry_url == "quay.io":
            input_registry_helper.auth()
        output_registry_helper.auth()
        return input_registry_helper, input_registry_helper


def main():
    """main function"""
    parser = argparse.ArgumentParser()
    parser.add_argument("command", type=Commands, choices=list(Commands))
    parser.add_argument("config", type=str,
                        help="point to image config in yaml formt")
    parser.add_argument("--publish", action="store_true", help="publish image")
    parser.add_argument(
        "--no-publish", dest="publish",
        action="store_false", help="dont publish image")
    parser.set_defaults(publish=False)
    parser.add_argument("--force-publish", dest="force_publish",
                        action="store_true", help="force publish image")
    parser.set_defaults(force_publish=False)
    parser.add_argument("--namespace", dest="namespace_name",
                        type=str, default="< n u l l >", help="name of namespace to use")
    parser.add_argument("--loglevel", type=str, default="info",
                        help="debug, info, warning, error")
    args = parser.parse_args()

    if args.force_publish:
        args.publish = True

    numeric_level = getattr(logging, args.loglevel.upper(), None)
    if not isinstance(numeric_level, int):
        raise ValueError(f"Invalid log level: {args.loglevel}")

    logging.basicConfig(
        level=numeric_level,
        format="[%(asctime)s] {%(pathname)s:%(lineno)d} %(levelname)s - %(message)s",
        datefmt="%H:%M:%S")

    logging.info(f"{args.command}, {args.config}")
    orchestrator = Orchestrator(args)
    orchestrator.run()


if __name__ == "__main__":
    main()
