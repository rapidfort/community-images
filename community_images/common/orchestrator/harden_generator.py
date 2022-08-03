""" Generates hardened images """

import os
import logging
import subprocess


class HardenGenerator:
    """ Harden generation command handler """
    def __init__(self, config_name, config_dict, docker_client, tag_mappings):
        self.config_name = config_name
        self.config_dict = config_dict
        self.docker_client = docker_client
        self.tag_mappings = tag_mappings
        self.script_dir = os.path.abspath(os.path.dirname( __file__ ))

    def generate(self, publish):
        """
        Create hardened images for all images which needs generation
        """
        image_script_dir = os.path.abspath(
                f"{self.script_dir}/../../{self.config_name}")

        rfignore_path = os.path.join(image_script_dir, ".rfignore")
        rfignore_exists = os.path.exists(rfignore_path)
        for tag_mapping in self.tag_mappings:
            if not tag_mapping.needs_generation:
                continue

            output_tag_details = tag_mapping.output_tag_details

            cmd=f"rfharden {output_tag_details.full_stub_tag} --put-meta"
            if rfignore_exists:
                cmd+=f" --profile {rfignore_path}"
            subprocess.check_output(cmd.split())

            if publish:
                # tag input stubbed image to output stubbed image
                hardened_image = self.docker_client.images.get(output_tag_details.full_hardened_tag)
                result = hardened_image.tag(output_tag_details.full_tag)
                logging.info(f"image tag:[{output_tag_details.full_tag}] success={result}")

                # push stubbed image to output repo
                result = self.docker_client.api.push(
                    output_tag_details.full_repo_path,
                    output_tag_details.tag)
                logging.info(f"docker client push result: {result}")
