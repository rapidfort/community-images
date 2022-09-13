""" Docker Registry Helper library """

import logging
import os
import requests
from consts import Consts


class RegistryHelper:
    """ Docker registry helper base class"""

    def __init__(self, docker_client, registry, username, password):
        self.registry = registry
        self.username = username
        self.password = password
        self.docker_client = docker_client

    @staticmethod
    def registry_url():
        """ Interface method to specify registry url"""

    # pylint: disable=unused-argument
    def fetch_tags(self, account, repo):
        """
        Interface method to fetch all tags for an image_repo
        Default returns latest
        """
        return Consts.LATEST

    def auth(self):
        """ auth docker client """
        self.docker_client.login(
            registry=self.registry,
            username=self.username,
            password=self.password)

    def get_latest_tag(self, account, repo, search_str):
        """
        Find latest tags using search_str"
        """
        tags = self.fetch_tags(account, repo)
        search_str_len = len(search_str)

        tags = filter(lambda tag: search_str in tag, tags)
        tags = list(filter(
            lambda tag: "rfstub" not in tag and tag[search_str_len:].rstrip(
            ).isdigit(),
            tags))

        if len(tags) == 0:
            return None

        tags.sort(key=lambda tag: int(tag[search_str_len:]))
        if tags:
            return tags[-1]
        return None

    def delete_tag(self, account, repo, tag):  # pylint: disable=unused-argument
        """ delete tag from repo """
        return True


class DockerHubHelper(RegistryHelper):
    """ Implement dockerhub helper """
    BASE_URL = "https://registry.hub.docker.com"

    def __init__(self, docker_client, registry):
        username = os.environ.get("DOCKERHUB_USERNAME")
        password = os.environ.get("DOCKERHUB_PASSWORD")
        super(__class__, self).__init__(
            docker_client, registry, username, password)

    @staticmethod
    def registry_url():
        return "docker.io"

    def fetch_tags(self, account, repo):
        """
        Get tags from the dockerhub registry API
        """
        tags = []

        url = f"{self.BASE_URL}/v2/repositories/{account}/{repo}/tags?page_size=25"

        if account == "_":
            # Handle official repository here
            url = f"{self.BASE_URL}/v2/repositories/{repo}/tags?page_size=25"

        while url:
            resp = requests.get(url, timeout=30)
            logging.debug(f"url : {url}, {resp.status_code}, {resp.text}")
            if 200 <= resp.status_code < 300:
                tag_objs = resp.json()
                results = tag_objs.get("results", [])
                tags += map(lambda x: x.get("name", ""), results)
                url = tag_objs.get("next")
            else:
                break

            # break after tags array is 100 size
            if len(tags) > 100:
                break
        return tags

    def get_auth_header(self):
        """ get auth header for JWT """
        login_url = f"{self.BASE_URL}/v2/users/login"
        resp = requests.post(
            login_url,
            json={
                "username": self.username,
                "password": self.password
            },
            timeout=30
        )
        if resp.status_code == 200:
            resp_json = resp.json()
            logging.debug(resp_json)
            token = resp_json["token"]
            return {"Authorization": f"JWT {token}"}
        return {}

    def delete_tag(self, account, repo, tag):
        del_url = f"{self.BASE_URL}/v2/repositories/{account}/{repo}/tags/{tag}/"
        auth_header = self.get_auth_header()
        resp = requests.delete(del_url, headers=auth_header, timeout=30)
        return resp.status_code == 200


class IronBankHelper(RegistryHelper):
    """ Iron bank helper class """

    def __init__(self, docker_client, registry):
        username = os.environ.get("IB_DOCKER_USERNAME")
        password = os.environ.get("IB_DOCKER_PASSWORD")
        super(__class__, self).__init__(
            docker_client, registry, username, password)

    @staticmethod
    def registry_url():
        return "registry1.dso.mil"


class RegistryHelperFactory:
    """ Registry factory to get Registry helper objects """
    REGISTRY_HELPER_CLS_LIST = [
        DockerHubHelper,
        IronBankHelper
    ]

    @classmethod
    def get_registry_helper(cls, docker_client, registry_url):
        """ Registry helper object creator """
        for reg_cls in cls.REGISTRY_HELPER_CLS_LIST:
            if reg_cls.registry_url() == registry_url:
                return reg_cls(docker_client, registry_url)
        return None
