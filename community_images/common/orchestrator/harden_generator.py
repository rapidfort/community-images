""" Generates hardened images """

import os
import logging
import tempfile
import backoff
from consts import Consts
from utils import Utils


class HardenGenerator:
    """ Harden generation command handler """

    def __init__(
            self,
            orchestrator,
            config_name,
            config_dict,
            docker_client,
            repo_set_mappings):
        self.orchestrator = orchestrator
        self.config_name = config_name
        self.config_dict = config_dict
        self.docker_client = docker_client
        self.repo_set_mappings = repo_set_mappings
        self.script_dir = os.path.abspath(os.path.dirname(__file__))

    def generate(self, publish):
        """
        Create hardened images for all images which needs generation
        """
        for tag_mappings in self.repo_set_mappings:
            try:
                self.generate_harden_for_tag_mappings(tag_mappings, publish)
            except Exception as exec:  # pylint:disable=broad-except
                logging.warning(
                    f"Harden generation failed for {tag_mappings} due to {exec}")
                raise

    def generate_harden_for_tag_mappings(self, tag_mappings, publish):
        """
        Generate hardened image for tag mappings
        """

        image_script_dir = os.path.abspath(
            f"{self.script_dir}/../../{self.config_name}")

        rfignore_path = os.path.join(image_script_dir, Consts.RF_IGNORE)
        rfignore_exists = os.path.exists(rfignore_path)
        for tag_mapping in tag_mappings:
            if not tag_mapping.needs_generation:
                continue

            output_tag_details = tag_mapping.output_tag_details

            # delete the tag
            self.orchestrator.output_registry_helper.delete_tag(
                output_tag_details.account,
                output_tag_details.repo,
                output_tag_details.stub_tag)

            rfharden_cmd = f"rfharden {output_tag_details.full_stub_tag} --put-meta -o {output_tag_details.full_hardened_tag}"
            if rfignore_exists:
                rfharden_cmd += f" --profile {rfignore_path}"

            self._run_harden_command(rfharden_cmd)

            if publish:
                # tag input stubbed image to output stubbed image
                hardened_image = self.docker_client.images.get(
                    output_tag_details.full_hardened_tag)
                result = hardened_image.tag(output_tag_details.full_tag)
                # build a new image to add an extra label
                labels = {
                    "orig_image_digest": output_tag_details.sha_digest
                }
                self._add_labels_to_image(
                    output_tag_details.full_tag,
                    labels=labels
                )
                logging.info(
                    f"image tag:[{output_tag_details.full_tag}] success={result}")

                # push hardened image to output repo
                result = self.docker_client.api.push(
                    output_tag_details.full_repo_path,
                    output_tag_details.tag)
                logging.info(f"docker client push result: {result}")

                if tag_mapping.is_latest:
                    self._tag_util(
                        output_tag_details.full_repo_path,
                        output_tag_details.tag, output_tag_details.sha_digest, Consts.LATEST)

                if tag_mapping.input_tag_details.account == Consts.BITNAMI:
                    self._roll_over_bitnami_tags(output_tag_details)

    def _add_labels_to_image(self, full_tag, labels=None):
        if not labels:
            return
        with tempfile.TemporaryDirectory() as tmp_dir:
            dockerfile = open(tmp_dir + '/' + 'Dockerfile', "w") # pylint: disable=unspecified-encoding, consider-using-with
            dockerfile.write(f'FROM {full_tag}')
            dockerfile.write('\n')
            for key, value in labels.items():
                dockerfile.write(f'LABEL {key}={value}')
                dockerfile.write('\n')
            dockerfile.close()
            result = self.docker_client.images.build(
                path=tmp_dir,
                dockerfile='Dockerfile',
                tag=full_tag,
                rm=True
            )
            logging.info(f"image built with tag:[{full_tag}] success={result}")

    @backoff.on_exception(backoff.expo, BaseException, max_time=3000) # 50 mins
    def _run_harden_command(self, rfharden_cmd): # pylint: disable=unused-argument
        """ Run harden command with backoff """
        Utils.run_cmd(rfharden_cmd.split())

    def _tag_util(self, full_repo_path, current_tag, sha_digest, new_tag):
        """ add new tag to existing image """
        # tag input stubbed image to output stubbed image
        src_image = self.docker_client.images.get(
            f"{full_repo_path}:{current_tag}")

        new_full_tag = f"{full_repo_path}:{new_tag}"
        result = src_image.tag(new_full_tag)
        logging.info(f"image tag:[{new_full_tag}] success={result}")
        labels = {
            "orig_image_digest": sha_digest
        }
        self._add_labels_to_image(new_full_tag, labels)

        # push stubbed image to output repo
        result = self.docker_client.api.push(
            full_repo_path,
            new_tag)
        logging.info(f"docker client push {new_full_tag} result: {result}")

    def _roll_over_bitnami_tags(self, tag_details):
        """ add bitnami rolling tags """
        # example tag=10.6.8-debian-10-r2
        input_tag = tag_details.tag
        input_tag_array = input_tag.split("-")
        if len(input_tag_array) < 3:
            logging.warning(f"unable to decode bitnami tag: {input_tag}")
            return

        version = input_tag_array[0]
        os_name = input_tag_array[1]
        os_ver = input_tag_array[2]

        # add version tag - 10.6.8
        self._tag_util(tag_details.full_repo_path, input_tag, tag_details.sha_digest, version)

        version_array = version.split(".")
        if len(version_array) < 2:
            logging.warning(f"unable to decode bitnami tag: {input_tag}")
            return

        maj_v = version_array[0]
        min_v = version_array[1]

        # 10.6-debian-10
        version_os_tag = f"{maj_v}.{min_v}-{os_name}-{os_ver}"
        major_minor_tag = f"{maj_v}.{min_v}"  # 10.6

        # add version os tag
        self._tag_util(
            tag_details.full_repo_path,
            input_tag, tag_details.sha_digest, version_os_tag)

        # add major minor tag
        self._tag_util(
            tag_details.full_repo_path,
            input_tag, tag_details.sha_digest, major_minor_tag)
