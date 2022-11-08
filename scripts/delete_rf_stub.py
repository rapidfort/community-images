import logging
import docker
import os
import urllib.parse
import re
import dateutil.parser
import backoff
from requests.auth import HTTPBasicAuth
import requests

class RegistryHelper:
    """ Docker registry helper base class"""

    def __init__(self, docker_client, username, password):
        self.username = username
        self.password = password
        self.docker_client = docker_client


class DockerHubHelper(RegistryHelper):
    """ Implement dockerhub helper """
    BASE_URL = "https://registry.hub.docker.com"

    def __init__(self, docker_client):
        username = os.environ.get("DOCKERHUB_USERNAME")
        password = os.environ.get("DOCKERHUB_PASSWORD")
        super(__class__, self).__init__(
            docker_client, username, password)

    @staticmethod
    def registry_url():
        return "docker.io"

    def get_rfstub_tag(self, account, repo):
        """
        Find rfstub tags using search_str"
        """
        tags = self._fetch_tags(account, repo)
        tags = list(filter(
            lambda tag: "rfstub" in tag["name"],
            tags))

        return tags


    def _fetch_tags(self, account, repo):
        """
        Get tags from the dockerhub registry API
        """
        tags = []

        url = f"{self.BASE_URL}/v2/repositories/{account}/{repo}/tags?page_size=25"

        if account == "_":
            # Handle official repository here
            url = f"{self.BASE_URL}/v2/repositories/{repo}/tags?page_size=25"

        while url:
            resp = requests.get(url, timeout=60)
            logging.debug(f"url : {url}, {resp.status_code}, {resp.text}")
            if 200 <= resp.status_code < 300:
                tag_objs = resp.json()
                tags += tag_objs.get("results", [])
                url = tag_objs.get("next")
            else:
                break

            # break after tags array is 10000 size
            if len(tags) > 10000:
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
        print(del_url)
        return resp.status_code == 200

if __name__ == "__main__":
    docker_client = docker.from_env()
    dh = DockerHubHelper(docker_client)
    tags = dh.get_rfstub_tag("rapidfort", "postgresql")
    for tag in tags:
        dh.delete_tag("rapidfort", "postgresql", tag)
