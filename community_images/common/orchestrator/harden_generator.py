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

                if tag_mapping.is_latest:
                    self._tag_util(
                        output_tag_details.full_repo_path,
                        output_tag_details.tag, "latest")

                if tag_mapping.input_tag_details.account == "bitnami":
                    self._roll_over_bitnami_tags(output_tag_details)

    def _tag_util(self, full_repo_path, current_tag, new_tag):
        """ add new tag to existing image """
        # tag input stubbed image to output stubbed image
        src_image = self.docker_client.images.get(f"{full_repo_path}:{current_tag}")

        new_full_tag = f"{full_repo_path}:{new_tag}"
        result = src_image.tag(new_full_tag)
        logging.info(f"image tag:[{new_full_tag}] success={result}")

        # push stubbed image to output repo
        result = self.docker_client.api.push(
            full_repo_path,
            new_tag)
        logging.info(f"docker client push {new_full_tag} result: {result}")

    def _roll_over_bitnami_tags(self, tag_details):
        """ add bitnami rolling tags """
        # example tag=10.6.8-debian-10-r2
        input_tag=tag_details.tag
        input_tag_array = input_tag.split("-")
        if len(input_tag_array) < 3:
            logging.warning(f"unable to decode bitnami tag: {input_tag}")
            return

        version = input_tag_array[0]
        os_name = input_tag_array[1]
        os_ver = input_tag_array[2]

        version_array = version.split(".")
        if len(version_array) < 2:
            logging.warning(f"unable to decode bitnami tag: {input_tag}")
            return

        maj_v = version_array[0]
        min_v = version_array[1]

        version_os_tag=f"{maj_v}.{min_v}-{os_name}-{os_ver}" # 10.6-debian-10
        major_minor_tag=f"{maj_v}-{min_v}" # 10.6

        # add version os tag
        self._tag_util(
            tag_details.full_repo_path,
            input_tag, version_os_tag)

        # add major minor tag
        self._tag_util(
            tag_details.full_repo_path,
            input_tag, major_minor_tag)
