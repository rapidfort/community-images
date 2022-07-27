""" Generates stub """

import logging
import subprocess

from registry_helper import RegistryFactory

# pylint:disable=too-few-public-methods
class StubGenerator:
    """ Stub generation command handler """
    def __init__(self, config_dict, docker_client, publish=False):
        self.config_dict = config_dict
        self.docker_client = docker_client
        self.publish = publish
        self.input_repo_obj, self.output_repo_obj = self._auth_registries()

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

        input_repo_obj = RegistryFactory.reg_helper_obj(
            self.docker_client, input_registry_url)

        output_repo_obj = RegistryFactory.reg_helper_obj(
            self.docker_client, output_registry_url)

        # authenticate to input and output registries
        input_repo_obj.auth()
        output_repo_obj.auth()

        return input_repo_obj, output_repo_obj

    def generate(self):
        """
        Walk through repo_sets objects to generate stub images
        repo_sets:
        - nats:
            input_base_tag: "2.8.4-debian-11-r"
            output_repo: nats
        """
        input_account = self.config_dict.get("input_registry", {}).get("account")

        repo_sets = self.config_dict.get("repo_sets", [])
        for repo_set in repo_sets:
            for input_repo, repo_values in repo_set.items():
                output_repo = repo_values.get("output_repo", input_repo)
                base_tag = repo_values.get("input_base_tag")

                needs_stub, latest_tag = self._check_stub_requirements(
                    input_repo, base_tag, output_repo)
                if not needs_stub:
                    continue

                self.docker_client.images.pull(
                    repository=f"{input_account}/{input_repo}",
                    tag=latest_tag
                    )
                full_image_tag=f"{input_account}/{input_repo}:{latest_tag}"
                subprocess.check_output(["rfstub", full_image_tag])

                self._stub_and_push(input_account, input_repo, latest_tag, output_repo)

    def _check_stub_requirements(self, input_repo, base_tag, output_repo):
        """Check if rfstub needs to be generate """

        input_account = self.config_dict.get("input_registry", {}).get("account")

        if base_tag != "latest":
            latest_tag = self.input_repo_obj.get_latest_tag(
                input_account, input_repo, base_tag)
            logging.info(f"got latest tag = {latest_tag}")

            if self.publish:
                output_account = self.config_dict.get("output_registry", {}).get("account")
                output_repo_latest_tag = self.output_repo_obj.get_latest_tag(
                    output_account, output_repo, base_tag)
                logging.info(f"got latest out tag = {output_repo_latest_tag}")
                if latest_tag == output_repo_latest_tag:
                    logging.info("Input and output tag matches for publish mode: CONTINUE")
                    return False, None
        else:
            latest_tag = base_tag
        return True, latest_tag

    def _stub_and_push(self, input_account, input_repo, latest_tag, output_repo):
        """ Stub the image and publish """
        output_registry = self.config_dict.get("output_registry")
        output_registry_url = output_registry.get("registry")
        output_account = output_registry.get("account")

        # get stubbed image
        stub_image_tag=f"{input_account}/{input_repo}:{latest_tag}-rfstub"
        stub_image = self.docker_client.images.get(stub_image_tag)

        # tag stubbed image with output repo
        # pylint:disable=line-too-long
        output_stub_tag = f"{output_registry_url}/{output_account}/{output_repo}:{latest_tag}-rfstub"
        result = stub_image.tag(output_stub_tag)
        logging.info(f"image tag:[{output_stub_tag}] success={result}")

        # push stubbed image to output repo
        result = self.docker_client.api.push(
            f"{output_registry_url}/{output_account}/{output_repo}",
            f"{latest_tag}-rfstub")
        logging.info(f"docker client push result: {result}")
