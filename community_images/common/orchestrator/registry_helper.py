""" Docker Registry Helper library """

import os
import subprocess
import sys
import requests

class RegistryHelper(object):
    def __init__(self, registry, username, password):
        self.registry = registry
        self.username = username
        self.password = password

    @staticmethod
    def registry_url():
        """ Interface method to specify registry url"""
        pass

    def fetch_tags(self, image_repo):
        """
        Interface method to fetch all tags for an image_repo
        Default returns latest
        """
        return "latest"

    def auth(self):
        logging.info("docker",
                "login",
                f"{self.registry}",
                f"-u {self.username}" ,
                f"-p {self.password}")
        exit_code = subprocess.call(
            [
                "docker",
                "login",
                f"{self.registry}",
                f"-u {self.username}" ,
                f"-p {self.password}"
            ])
        return exit_code

    def get_latest_tag(self, account, repo, search_str):
        """
        Find latest tags using search_str"
        """
        tags = self.fetch_tags(account, repo)
        search_str_len = len(search_str)

        tags = filter(lambda tag: search_str in tag, tags)
        tags = list(filter(
            lambda tag: "rfstub" not in tag and tag[search_str_len:].rstrip().isdigit(),
            tags))

        if len(tags)==0:
            return

        tags.sort(key = lambda tag: int(tag[search_str_len:]))
        if tags:
            return tags[-1]

    def delete_tag(self, account, repo, tag):
        return True


class DockerHubHelper(RegistryHelper):
    BASE_URL = "https://registry.hub.docker.com"
    def __init__(self, registry):
        username = os.environ.get("DOCKERHUB_USERNAME")
        password = os.environ.get("DOCKERHUB_PASSWORD")
        super(DockerHubHelper, self).__init__(registry, username, password)
    
    @staticmethod
    def registry_url():
        return "docker.io"

    def fetch_tags(self, account, repo):
        """
        Get tags from the dockerhub registry API
        """
        tags=[]

        url = f"{self.BASE_URL}/v1/repositories/{account}/{repo}/tags"

        if account == "_":
            # Handle official repository here
            url = f"{self.BASE_URL}/v1/repositories/{repo}/tags"

        resp = requests.get(url)
        if 200 <= resp.status_code < 300:
            tag_objs = resp.json()
            tags = map(lambda x: x.get("name", ""), tag_objs)
        return tags

    def get_auth_header(self):
        login_url = f"{self.BASE_URL}/v2/users/login"
        resp = requests.post(
            login_url,
            json={
                "username": self.username,
                "password": self.password
                }
            )
        if resp.status_code == 200:
            resp_json = resp.json()
            logging.debug(resp_json)
            token = resp_json["token"]
            return {"Authorization": f"JWT {token}"}

    def delete_tag(self, account, repo, tag):
        del_url = f"{self.BASE_URL}/v2/repositories/{account}/{repo}/tags/{tag}/"
        auth_header = self.get_auth_header()
        resp = requests.delete(del_url, headers=auth_header)
        return True if resp.status_code == 200 else False

class IronBankHelper(RegistryHelper):
    def __init__(self):
        username = os.environ.get("IB_DOCKER_USERNAME")
        password = os.environ.get("IB_DOCKER_PASSWORD")
        super(IronBankHelper, self).__init__(registry, username, password)

    @staticmethod
    def registry_url():
        return "registry1.dso.mil"

class RegistryFactory:
    REGISTRY_HELPER_CLS_LIST = [
        DockerHubHelper,
        IronBankHelper
    ]

    @classmethod
    def reg_helper_obj(cls, registry_url):
        for reg_cls in cls.REGISTRY_HELPER_CLS_LIST:
            if reg_cls.registry_url() == registry_url:
                return reg_cls(registry_url)
