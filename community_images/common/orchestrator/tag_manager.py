""" Tag Manager module """

import logging
import os
import random

class TagDetail:
    """ Tag Details class """

    def __init__(self, registry, account, repo, tag, sha_digest):
        self.registry = registry
        self.account = account
        self.repo = repo
        self.tag = tag
        self.sha_digest = sha_digest

    @property
    def repo_path(self):
        """ Full repo path """
        return "/".join([self.account, self.repo])

    @property
    def full_repo_path(self):
        """ Full repo path """
        return "/".join([self.registry, self.account, self.repo])

    @property
    def stub_tag(self):
        """ Stub tag """
        return f"{self.tag}-rfstub"

    @property
    def hardened_tag(self):
        """ Hardened tag """
        return f"{self.tag}-rfhardened"

    @property
    def full_tag(self):
        """ Full tag """
        return f"{self.full_repo_path}:{self.tag}"

    @property
    def full_stub_tag(self):
        """ Full stub tag """
        return f"{self.full_repo_path}:{self.stub_tag}"

    @property
    def full_hardened_tag(self):
        """ Full Hardened tag """
        return f"{self.full_repo_path}:{self.hardened_tag}"

    @property
    def tag_with_digest(self):
        """ Tag:Digest """
        return f"{self.tag}:{self.sha_digest}"

# pylint: disable=too-few-public-methods
class TagMapping:
    """ Tag mapping class """

    def __init__(
            self,
            input_tag_details,
            output_tag_details,
            needs_generation,
            is_latest=False):
        self.input_tag_details = input_tag_details
        self.output_tag_details = output_tag_details
        self.needs_generation = needs_generation
        self.is_latest = is_latest

    def set_needs_generation(self, needs_generation):
        """set the needs generation."""
        self.needs_generation = needs_generation


# pylint: disable=logging-fstring-interpolation
class TagManager:
    """ Tag Manager main class """

    def __init__(self, orchestrator):
        """ Tag Manager init """
        self.orchestrator = orchestrator
        self.config_name = self.orchestrator.config_name
        self.config_dict = self.orchestrator.config_dict
        self.repo_set_mappings = self._prepare_repo_set_mappings()

    def _get_registry_account(self, registry_str):
        """ Get registry, account from registry_str """
        registry_dict = self.config_dict.get(registry_str)
        registry = registry_dict.get("registry")
        account = registry_dict.get("account")
        return registry, account

    # pylint: disable=too-many-arguments
    def _get_tag_detail(self, registry, account, registry_helper, repo, base_tag):
        """Generate tag details object"""
        latest_tag = None

        if base_tag != "latest":
            latest_tag, latest_digest = registry_helper.get_latest_tag_with_digest(
                account, repo, base_tag)

        latest_tag = latest_tag or "latest"
        latest_digest = latest_digest or "%032x" % random.getrandbits(256) # pylint: disable=consider-using-f-string

        logging.info(
            f"got latest tag = {account}, {repo}, {latest_tag} for base_tag = {base_tag}")
        return TagDetail(registry, account, repo, latest_tag, latest_digest)

    def _prepare_repo_set_mappings(self): # pylint:disable=too-many-locals
        """
        Uses schema to prepare tag list
        repo_sets:
        - nats:
            input_base_tag: "2.8.4-debian-11-r"
            output_repo: nats
        """
        repo_set_mappings = []
        repo_sets = self.config_dict.get("repo_sets", [])
        is_image_generation_required_for_any_container = False
        for index, repo_set in enumerate(repo_sets):
            tag_mappings = []
            for input_repo, repo_values in repo_set.items():

                output_repo = repo_values.get("output_repo", input_repo)
                base_tag = repo_values.get("input_base_tag")

                input_registry, input_account = self._get_registry_account(
                    "input_registry"
                )

                input_tag_detail = self._get_tag_detail(
                    input_registry, input_account,
                    self.orchestrator.input_registry_helper,
                    input_repo, base_tag)

                output_registry = os.environ.get(
                    "RAPIDFORT_OUTPUT_REGISTRY", "docker.io")
                output_account = os.environ.get(
                    "RAPIDFORT_ACCOUNT", "rapidfort")

                output_tag_detail = self._get_tag_detail(
                    output_registry, output_account,
                    self.orchestrator.output_registry_helper,
                    output_repo, base_tag)
                output_tag_detail.sha_digest = self.orchestrator.output_registry_helper.get_digest_from_label(
                    output_tag_detail.full_tag)

                # we need to generate new image, if
                # 1. We are not publishing and just doing a ci/cd test
                # 2. We are force publishing
                # 3. Input and output tag dont match
                logging.info(f"input tag with digest details={input_tag_detail.tag_with_digest}")
                logging.info(f"output tag with digest details={output_tag_detail.tag_with_digest}")
                logging.info(f"publish flag={self.orchestrator.publish}")
                logging.info(
                    f"force publish flag={self.orchestrator.force_publish}")

                needs_generation = (
                    not self.orchestrator.publish or self.orchestrator.force_publish or (
                        input_tag_detail.tag_with_digest != output_tag_detail.tag_with_digest))
                is_image_generation_required_for_any_container =(
                    needs_generation or is_image_generation_required_for_any_container
                )
                logging.info(
                    f"decision for needs generation={needs_generation}")

                # output tag needs to be same as input tag
                output_tag_detail.tag = input_tag_detail.tag
                output_tag_detail.sha_digest = input_tag_detail.sha_digest

                is_latest = (index == 0)
                tag_mapping = TagMapping(
                    input_tag_detail,
                    output_tag_detail,
                    needs_generation,
                    is_latest)
                tag_mappings.append(tag_mapping)
            # if image generation is needed for any of the container in multi container
            # image, then we should generate it for all container image
            for tag_mapping in tag_mappings:
                tag_mapping.set_needs_generation(is_image_generation_required_for_any_container)
            repo_set_mappings.append(tag_mappings)

        return repo_set_mappings
