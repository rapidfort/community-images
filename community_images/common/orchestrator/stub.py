""" Generates stub """

import logging
import subprocess

from registry_helper import RegistryFactory

class StubGenerator:
    def __init__(self, config_dict, docker_client, publish=False):
        self.config_dict = config_dict
        self.docker_client = docker_client
        self.publish = publish

    def generate(self):
        """
        Parses image.yml for below structure and generates stub
q
        input_registry:
            registry: docker.io
            account: bitnami
        output_registry:
            registry: docker.io
            account: rapidfort
        repos:
        - input_repo: nats
            input_base_tags:
            - "2.8.4-debian-11-r"
            output_repo: nats
        """
        repos = self.config_dict.get("repos", [])
        input_registry = self.config_dict.get("input_registry")
        input_registry_url = input_registry.get("registry")
        input_account = input_registry.get("account")

        output_registry = self.config_dict.get("output_registry")
        output_registry_url = output_registry.get("registry")
        output_account = output_registry.get("account")

        input_repo_obj = RegistryFactory.reg_helper_obj(
            self.docker_client, input_registry_url)

        output_repo_obj = RegistryFactory.reg_helper_obj(
            self.docker_client, output_registry_url)

        input_repo_obj.auth()
        output_repo_obj.auth()

        for repo in repos:
            input_repo = repo.get("input_repo")
            output_repo = repo.get("output_repo")
            input_base_tags = repo.get("input_base_tags", [])

            for base_tag in input_base_tags:
                
                if base_tag != "latest":
                    latest_tag = input_repo_obj.get_latest_tag(
                        input_account, input_repo, base_tag)
                    
                    logging.info(f"got latest tag = {latest_tag}")

                    if self.publish:
                        output_repo_latest_tag = output_repo_obj.get_latest_tag(
                            output_account, output_repo, base_tag)
                        
                        logging.info(f"got latest out tag = {output_repo_latest_tag}")
                        if latest_tag == output_repo_latest_tag:
                            logging.info("Input and output tag matches for publish mode: CONTINUE")
                            continue
                else:
                    latest_tag = base_tag

                docker_image = self.docker_client.images.pull(
                    repository=f"{input_account}/{input_repo}",
                    tag=latest_tag
                    )
                full_image_tag=f"{input_account}/{input_repo}:{latest_tag}"
                subprocess.run(["rfstub", full_image_tag])

                self.stub_and_push(input_account, input_repo, latest_tag, output_repo)

    def stub_and_push(self, input_account, input_repo, latest_tag, output_repo):
        output_registry = self.config_dict.get("output_registry")
        output_registry_url = output_registry.get("registry")
        output_account = output_registry.get("account")

        # get stubbed image
        stub_image_tag=f"{input_account}/{input_repo}:{latest_tag}-rfstub"
        stub_image = self.docker_client.images.get(stub_image_tag)

        # tag stubbed image with output repo
        output_stub_tag = f"{output_registry_url}/{output_account}/{output_repo}:{latest_tag}-rfstub"
        result = stub_image.tag(output_stub_tag)
        logging.info(f"image tag:[{output_stub_tag}] success={result}")

        # push stubbed image to output repo
        result = self.docker_client.api.push(
            f"{output_registry_url}/{output_account}/{output_repo}",
            f"{latest_tag}-rfstub")
        logging.info(f"docker client push result: {result}")
