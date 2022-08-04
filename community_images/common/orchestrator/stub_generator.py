""" Generates stub """

import logging
import subprocess


class StubGenerator:
    """ Stub generation command handler """
    def __init__(self, config_name, config_dict, docker_client, tag_mappings):
        self.config_name = config_name
        self.config_dict = config_dict
        self.docker_client = docker_client
        self.tag_mappings = tag_mappings

    def generate(self):
        """
        Create stub images for all images which needs generation
        """
        for tag_mapping in self.tag_mappings:
            if not tag_mapping.needs_generation:
                continue

            input_tag_details = tag_mapping.input_tag_details
            output_tag_details = tag_mapping.output_tag_details

            # pull docker image
            self.docker_client.images.pull(
                repository=input_tag_details.full_repo_path,
                tag=input_tag_details.tag
            )
            subprocess.check_output(["rfstub", input_tag_details.full_tag])

            # tag input stubbed image to output stubbed image
            stub_image = self.docker_client.images.get(input_tag_details.full_stub_tag)
            result = stub_image.tag(output_tag_details.full_stub_tag)
            logging.info(f"image tag:[{output_tag_details.full_stub_tag}] success={result}")

            # push stubbed image to output repo
            result = self.docker_client.api.push(
                output_tag_details.full_repo_path,
                output_tag_details.stub_tag)
            logging.info(f"docker client push result: {result}")
