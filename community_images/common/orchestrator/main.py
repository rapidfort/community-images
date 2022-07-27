""" Orchestrator for Community Images """

import argparse
from enum import Enum
import logging
import os

import docker
from stub import StubGenerator
import yaml

class Commands(Enum):
    """Enum for commands"""
    STUB = 'stub'
    STUB_COVERAGE = 'stub_coverage'
    HARDEN = 'harden'
    HARDEN_COVERAGE = 'harden_coverage'

    def __str__(self):
        return self.value.lower()

def load_config(config_name: str) -> dict:
    """load config file"""
    script_dir = os.path.abspath(os.path.dirname( __file__ ))
    config_path = os.path.join(f"{script_dir}/../../{config_name}/image.yml")
    with open(config_path, encoding='UTF-8') as config_fp:
        config_dict = yaml.load(config_fp, Loader=yaml.FullLoader)
        logging.info(f"config_dict={config_dict}")
        return config_dict

def run(command: Commands, config_dict: dict, docker_client, publish) -> None:
    """run commands for orchestrator"""
    if command == Commands.STUB:
        stub = StubGenerator(config_dict, docker_client, publish)
        stub.generate()


def main():
    """main function"""
    parser = argparse.ArgumentParser()
    parser.add_argument("command", type=Commands, choices=list(Commands),
                    help="[stub, stub_coverage, harden, harden_coverage]")
    parser.add_argument("config", type=str, help="point to image config in yaml formt")
    parser.add_argument("--publish", action='store_true', help="publish image")
    parser.add_argument(
        '--no-publish', dest='publish',
        action='store_false', help="dont publish image")
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
    config_dict = load_config(args.config)
    docker_client = docker.from_env()
    run(args.command, config_dict, docker_client, args.publish)

if __name__ == "__main__":
    main()
