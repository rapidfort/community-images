""" Tag Manager module """

import logging

class TagDetail:
    """ Tag Details class """
    def __init__(self, registry, account, repo, tag):
        self.registry = registry
        self.account = account
        self.repo = repo
        self.tag = tag

    @property
    def repo_path(self):
        """ Full repo path """
        return "/".join([self.account,self.repo])

    @property
    def full_repo_path(self):
        """ Full repo path """
        return "/".join([self.registry,self.account,self.repo])

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


class TagManager:
    """ Tag Manager main class """
    def __init__(self, orchestrator):
        """ Tag Manager init """
        self.orchestrator = orchestrator
        self.config_name = self.orchestrator.config_name
        self.config_dict = self.orchestrator.config_dict
        self.tag_mappings = self._prepare_tag_mappings()

    def _get_tag_detail(self, registry_str, registry_helper, repo, base_tag):
        """Generate tag details object"""
        registry_dict = self.config_dict.get(registry_str)
        registry = registry_dict.get("registry")
        account = registry_dict.get("account")

        if base_tag != "latest":
            latest_tag = registry_helper.get_latest_tag(account, repo, base_tag)
        else:
            latest_tag = base_tag

        logging.info(f"got latest tag = {account}, {repo}, {latest_tag} for base_tag = {base_tag}")
        return TagDetail(registry, account, repo, latest_tag)

    def _prepare_tag_mappings(self):
        """
        Uses schema to prepare tag list
        repo_sets:
        - nats:
            input_base_tag: "2.8.4-debian-11-r"
            output_repo: nats
        """
        tag_mappings = []
        repo_sets = self.config_dict.get("repo_sets", [])
        for index, repo_set in enumerate(repo_sets):
            for input_repo, repo_values in repo_set.items():

                output_repo = repo_values.get("output_repo", input_repo)
                base_tag = repo_values.get("input_base_tag")

                input_tag_detail = self._get_tag_detail(
                    "input_registry",
                    self.orchestrator.input_registry_helper,
                        input_repo, base_tag)

                output_tag_detail = self._get_tag_detail(
                    "output_registry",
                    self.orchestrator.output_registry_helper,
                        output_repo, base_tag)

                # we need to generate new image, if
                # 1. We are not publishing and just doing a ci/cd test
                # 2. We are force publishing
                # 3. Input and output tag dont match
                logging.info(f"input tag details={input_tag_detail.tag}")
                logging.info(f"input tag details={output_tag_detail.tag}")
                logging.info(f"publish flag={self.orchestrator.publish}")
                logging.info(f"force publish flag={self.orchestrator.force_publish}")

                needs_generation = (not self.orchestrator.publish or
                    self.orchestrator.force_publish or
                    (input_tag_detail.tag != output_tag_detail.tag))
                logging.info(f"decision for needs generation={needs_generation}")

                if not output_tag_detail.tag:
                    output_tag_detail.tag = input_tag_detail.tag

                is_latest = (index==0)
                tag_mapping = TagMapping(
                    input_tag_detail,
                    output_tag_detail,
                    needs_generation,
                    is_latest)
                tag_mappings.append(tag_mapping)

        return tag_mappings
