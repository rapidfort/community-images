""" Docker Registry Helper library """

import logging
import os
import random
import urllib.parse
import re
import dateutil.parser
import backoff
from requests.auth import HTTPBasicAuth
import requests
from consts import Consts
from docker.errors import ImageNotFound, NotFound


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
    def get_latest_tag_with_digest(self, account, repo, search_str):
        """
        Find latest tags using search_str
        """
        return Consts.LATEST

    def get_digest_from_label(self, image_path):
        """
        Find the digest using image label
        """
        # pull the image first
        try:
            self.docker_client.images.pull(image_path)
            image = self.docker_client.images.get(image_path)
            return image.labels.get('orig_image_digest', '')
        except (ImageNotFound, NotFound):
            digest = "%032x" % random.getrandbits(256) # pylint: disable=consider-using-f-string
            logging.info(f'Image {image_path} not found, returning digest: {digest}')
            return digest

    def find_version_tag_for_rolling_tag(self, account, repo, rolling_tag):
        """
        Search version tag for a rolling tag
        For example: given rolling_tag latest, this function should return v3.x.x
        This is achieved by fetching tags, finding all the tags which have
        same digest as the rolling_tag and then returning the longest string
        """

    @backoff.on_exception(backoff.expo, BaseException, max_time=300)
    def auth(self):
        """ auth docker client """
        self.docker_client.login(
            registry=self.registry,
            username=self.username,
            password=self.password)


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

    def get_latest_tag_with_digest(self, account, repo, search_str):
        """
        Find latest tags using search_str"
        """
        tags = self._fetch_tags(account, repo)
        search_pattern = re.compile(search_str)
        tags = filter(lambda tag: search_pattern.match(tag["name"]), tags)
        tags = list(filter(lambda tag: "rfstub" not in tag["name"] and tag["tag_last_pushed"] and \
                any(image.get('os', '') == 'linux' for image in tag.get('images', [])), tags))

        if len(tags) == 0:
            tags = self._fetch_tags(account, repo, deep = True)
            tags = filter(lambda tag: search_pattern.match(tag["name"]), tags)
            tags = list(filter(lambda tag: "rfstub" not in tag["name"] and tag["tag_last_pushed"] and \
                    any(image.get('os', '') == 'linux' for image in tag.get('images', [])), tags))
            if len(tags) == 0:
                return None, None

        tags.sort(key=lambda tag: dateutil.parser.parse(
            tag["tag_last_pushed"]))
        if tags:
            return tags[-1]["name"], tags[-1]["digest"]
        return None, None

    def find_version_tag_for_rolling_tag(self, account, repo, rolling_tag):
        """
        Search version tag for a rolling tag
        For example: given rolling_tag latest, this function should return v3.x.x
        This is achieved by fetching tags, finding all the tags which have
        same digest as the rolling_tag and then returning the longest string
        """
        tags = self._fetch_tags(account, repo)

        found_rolling_tag = None
        for tag in tags:
            if rolling_tag == tag.get("name"):
                found_rolling_tag = tag
                break

        if not found_rolling_tag:
            return None

        rolling_tag_digest = found_rolling_tag.get("digest")
        tags = list(filter(
            lambda tag: tag.get("digest") and tag.get("name") and\
                any(image.get('os', '') == 'linux' for image in tag.get('images', [])) and\
                rolling_tag_digest == tag["digest"] and tag["name"] != rolling_tag,
            tags))

        tags.sort(key=lambda tag: len(tag["name"]), reverse = True)

        if tags:
            return tags[0]["name"]
        return None


    def _fetch_tags(self, account, repo, deep = False):
        """
        Get tags from the dockerhub registry API
        """
        tags = []
        if deep:
            logging.info("Trying Deep Search")
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

            # break after tags array is 200 size
            if (not deep) and len(tags) > 200:
                break
            if deep and len(tags) > 5000:
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
    BASE_URL = "https://registry1.dso.mil"

    def __init__(self, docker_client, registry):
        username = os.environ.get("IB_DOCKER_USERNAME")
        password = os.environ.get("IB_DOCKER_PASSWORD")
        super(__class__, self).__init__(
            docker_client, registry, username, password)

    @staticmethod
    def registry_url():
        return "registry1.dso.mil"

    def get_latest_tag_with_digest(self, account, repo, search_str):
        """
        Find latest tags using search_str"
        """
        tags = self._fetch_tags(account, repo)
        tags = filter(lambda tag: search_str in tag["name"], tags)
        tags = list(filter(
            lambda tag: "sha" not in tag["name"],
            tags))

        if len(tags) == 0:
            return None, None

        if account == os.environ.get("RAPIDFORT_ACCOUNT", "rapidfort"):
            tags.sort(key=lambda tag: dateutil.parser.parse(tag["tag_last_pushed"]))
        else:
            tags.sort(key=lambda tag: dateutil.parser.parse(tag["push_time"]))
        if tags:
            return tags[-1]["name"], tags[-1]["digest"]
        return None, None


    def _fetch_tags(self, account, repo):
        """
        Get tags from the dockerhub registry API
        """
        tags = []
        if account == os.environ.get("RAPIDFORT_ACCOUNT", "rapidfort"):
            url = f"https://registry.hub.docker.com/v2/repositories/{account}/{repo}/tags?page_size=25"
            while url and len(tags) <= 200:
                resp = requests.get(url, timeout=60)
                logging.debug(f"url : {url}, {resp.status_code}, {resp.text}")
                if 200 <= resp.status_code < 300:
                    tags += resp.json().get("results", [])
                    url = resp.json().get("next")
                else:
                    break
        else:
            url_safe_repo = urllib.parse.quote(repo, safe='')
            url = f"{self.BASE_URL}/api/v2.0/projects/{account}/repositories/{url_safe_repo}/artifacts?page_size=100"
            auth = HTTPBasicAuth(self.username, self.password)

            for page in range(0, 100):
                page_url = f"{url}&page={page}"
                resp = requests.get(page_url, auth=auth, timeout=120)
                logging.debug(f"page_url: {page_url}, {resp.status_code}, {resp.text}")

                if not 200 <= resp.status_code < 300:
                    break
                artifacts = resp.json()
                if len(artifacts) == 0:
                    break

                for artifact in artifacts:
                    local_tag_list = artifact.get("tags")
                    logging.debug(f"artifact={artifact}")
                    if local_tag_list:
                        sha_digest = artifact.get("digest")
                        for local_tag in local_tag_list:
                            local_tag["digest"] = sha_digest
                        tags += local_tag_list

        return tags

    def get_auth_header(self):
        """ get auth header for JWT """
        login_url = "https://registry.hub.docker.com/v2/users/login"
        dockerhub_username = os.environ.get("DOCKERHUB_USERNAME")
        dockerhub_password = os.environ.get("DOCKERHUB_PASSWORD")
        resp = requests.post(
            login_url,
            json={
                "username": dockerhub_username,
                "password": dockerhub_password
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
        del_url = f"https://registry.hub.docker.com/v2/repositories/{account}/{repo}/tags/{tag}/"
        logging.info("Deleting from %s", del_url)
        auth_header = self.get_auth_header()
        resp = requests.delete(del_url, headers=auth_header, timeout=30)
        return resp.status_code == 200

class QuayHelper(RegistryHelper):
    """ Implement Quay.io helper """
    BASE_URL = "https://quay.io/api/v1/"

    def __init__(self, docker_client, registry):
        username = os.environ.get("QUAY_USERNAME")
        password = os.environ.get("QUAY_PASSWORD")
        super().__init__(docker_client, registry, username, password)

    @staticmethod
    def registry_url():
        return "quay.io"

    def get_auth_header(self):
        """ get auth header for JWT """
        login_url = "https://registry.hub.docker.com/v2/users/login"
        dockerhub_username = os.environ.get("DOCKERHUB_USERNAME")
        dockerhub_password = os.environ.get("DOCKERHUB_PASSWORD")
        resp = requests.post(
            login_url,
            json={
                "username": dockerhub_username,
                "password": dockerhub_password
            },
            timeout=30
        )
        if resp.status_code == 200:
            resp_json = resp.json()
            logging.debug(resp_json)
            token = resp_json["token"]
            return {"Authorization": f"JWT {token}"}
        return {}

    def _fetch_tags(self, account, repo): # pylint: disable=too-many-locals
        """ Fetch tags from Quay.io """
        # Implement fetching tags from Quay.io
        # Adjust the URL and parameters according to Quay's API documentation.
        tags = []
        if account == os.environ.get("RAPIDFORT_ACCOUNT", "rapidfort"):
            url = f"https://registry.hub.docker.com/v2/repositories/{account}/{repo}/tags?page_size=25"
            while url and len(tags) <= 200:
                resp = requests.get(url, timeout=60)
                logging.debug(f"url : {url}, {resp.status_code}, {resp.text}")
                if 200 <= resp.status_code < 300:
                    tags += resp.json().get("results", [])
                    url = resp.json().get("next")
                else:
                    break
        else:
            url_safe_repo = urllib.parse.quote(f'{account}/{repo}', safe='')
            url = f"{self.BASE_URL}repository/{url_safe_repo}/tag/"
            page = 1
            has_next_page = True
            while has_next_page:
                page_url = f"{url}?page={page}&limit=100"
                resp = requests.get(page_url, timeout=120)
                logging.debug(f"page_url: {page_url}, {resp.status_code}, {resp.text}")

                if not 200 <= resp.status_code < 300:
                    break
                data = resp.json()
                page_tags = data.get('tags', [])
                if not page_tags:
                    break

                for tag in page_tags:
                    # Assuming each tag object in Quay.io's response has 'name' 'manifest_digest' fields
                    if 'name' in tag and 'manifest_digest' in tag:
                        tags.append({'name': tag['name'], 'digest': tag['manifest_digest'], 'last_modified': tag.get('last_modified')})
                page += 1
                has_next_page = 'has_additional' in data

        return tags

    def get_latest_tag_with_digest(self, account, repo, search_str):
        """ Find the latest tag using search_str """
        tags = self._fetch_tags(account, repo)
        tags = filter(lambda tag: search_str in tag["name"], tags)
        tags = list(filter(lambda tag: "sha" not in tag["name"], tags))

        if not tags:
            return None, None

        # Example sorting, adjust if Quay.io's tag object structure differs
        if account == os.environ.get("RAPIDFORT_ACCOUNT", "rapidfort"):
            tags.sort(key=lambda tag: dateutil.parser.parse(tag["tag_last_pushed"]))
        else:
            tags.sort(key=lambda tag: dateutil.parser.parse(tag["last_modified"]))
        if tags:
            latest_tag = tags[-1]
            return latest_tag["name"], latest_tag.get("digest", None)
        return None, None

    def delete_tag(self, account, repo, tag):
        del_url = f"https://registry.hub.docker.com/v2/repositories/{account}/{repo}/tags/{tag}/"
        logging.info("Deleting from %s", del_url)
        auth_header = self.get_auth_header()
        resp = requests.delete(del_url, headers=auth_header, timeout=30)
        return resp.status_code == 200

class RegistryHelperFactory:
    """ Registry factory to get Registry helper objects """
    REGISTRY_HELPER_CLS_LIST = [
        DockerHubHelper,
        IronBankHelper,
        QuayHelper
    ]

    @classmethod
    def get_registry_helper(cls, docker_client, registry_url):
        """ Registry helper object creator """
        for reg_cls in cls.REGISTRY_HELPER_CLS_LIST:
            if reg_cls.registry_url() == registry_url:
                return reg_cls(docker_client, registry_url)
        return None
