""" Generates stub """

import logging
import os
import shutil
import tempfile
import backoff
from consts import Consts
from utils import Utils


class StubGenerator:
    """ Stub generation command handler """

    def __init__(
            self,
            config_name,
            config_dict,
            docker_client,
            repo_set_mappings):
        self.config_name = config_name
        self.config_dict = config_dict
        self.docker_client = docker_client
        self.repo_set_mappings = repo_set_mappings

    def generate(self):
        """
        Create stub images for all images which needs generation
        """
        for tag_mappings in self.repo_set_mappings:
            try:
                self.generate_stub_for_tag_mappings(tag_mappings)
            except Exception as exec:  # pylint:disable=broad-except
                logging.warning(
                    f"Stub generation failed for {tag_mappings} due to {exec}")
                raise

    def generate_stub_for_tag_mappings(self, tag_mappings):
        """
        Generate stubs for tag mappings
        """
        for tag_mapping in tag_mappings:
            if not tag_mapping.needs_generation:
                continue

            input_tag_details = tag_mapping.input_tag_details
            output_tag_details = tag_mapping.output_tag_details
            logging.info(
                f"output tag.full_stub_tag:[{output_tag_details.full_stub_tag}]")
            logging.info(
                f"input tag.full_stub_tag:[{input_tag_details.full_stub_tag}]")


            if tag_mapping.input_tag_details.account == Consts.BITNAMI:
                # create image with RapidFort banner
                self._add_rf_banner(tag_mapping.input_tag_details)
            else:
                # pull docker image
                self.docker_client.images.pull(
                    repository=input_tag_details.full_repo_path,
                    tag=input_tag_details.tag
                )

            self._run_stub_command(input_tag_details.full_tag)
            # tag input stubbed image to output stubbed image
            stub_image = self.docker_client.images.get(
                input_tag_details.full_stub_tag)
            result = stub_image.tag(output_tag_details.full_stub_tag)
            logging.info(
                f"image tag:[{output_tag_details.full_stub_tag}] success={result}")
            # push stubbed image to output repo
            result = self.docker_client.api.push(
                output_tag_details.full_repo_path,
                output_tag_details.stub_tag)
            logging.info(f"docker client push result: {result}")
            # Remove original input image to clean up space
            logging.info(f"Removing original input image: [{input_tag_details.full_tag}]")
            self.docker_client.images.remove(input_tag_details.full_stub_tag)

    @backoff.on_exception(backoff.expo, BaseException, max_time=3000) # 50 mins
    def _run_stub_command(self, tag): # pylint: disable=unused-argument
        """ Run stub command with backoff """
        cmd = "rfstub "
        if self.config_dict.get("use_rapid_stub", False):
            cmd += "-s rapid "
        cmd += tag
        Utils.run_cmd(cmd.split())

    def _add_rf_banner(self, tag_details):
        """ Add RapidFort banner in bitnami images """
        logging.info(f"Adding rapidfort banner for image: {tag_details}")

        with tempfile.TemporaryDirectory() as tmpdirname:
            is_locked=self.config_dict.get("is_locked")
            script_dir = os.path.abspath(os.path.dirname(__file__))

            # copy over libbitnami.sh file
            src = os.path.join(script_dir, "../libbitnami.sh")
            dst = os.path.join(tmpdirname, "libbitnami.sh")
            shutil.copyfile(src, dst)
            # copy over libbitnami-h.sh file
            src = os.path.join(script_dir, "../libbitnami-h.sh")
            dst = os.path.join(tmpdirname, "libbitnami-h.sh")
            shutil.copyfile(src, dst)
            src = os.path.join(script_dir, "../.rapidfort_RtmF")
            dst = os.path.join(tmpdirname, ".rapidfort_RtmF")
            shutil.copytree(src, dst)

            # create docker file
            file_path = os.path.join(tmpdirname, "Dockerfile")
            with open(file_path, 'w', encoding="UTF-8") as dckr_fp:
                dckr_fp.write(
                    f"FROM {tag_details.repo_path}:{tag_details.tag}\n")
                dckr_fp.write(
                    "ADD libbitnami.sh /opt/bitnami/scripts/libbitnami.sh\n")
                if is_locked == "True":
                    dckr_fp.write(
                        "ADD libbitnami-h.sh /opt/bitnami/scripts/libbitnami.sh\n")
                    dckr_fp.write(
                        'ADD .rapidfort_RtmF /.rapidfort_RtmF\n')
                    dckr_fp.write(
                        'USER root\n')
                    dckr_fp.write(
                        'RUN mkdir -p /.rapidfort_RtmF/.gnupg\n')
                    dckr_fp.write(
                        'RUN chmod -R 777 /.rapidfort_RtmF\n')
                    dckr_fp.write(
                        'USER 1001\n')

            # run docker build
            image, log_generator = self.docker_client.images.build(
                path=tmpdirname)
            for log_lines in log_generator:
                logging.info(log_lines)
            result = image.tag(tag_details.full_tag)
            logging.info(
                f"rf banner image tag:[{tag_details.full_stub_tag}] success={result}")
