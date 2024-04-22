"""
This workflow script gets the repo_sets/base_tags/search_expressions for every image in image.lst 
and fetches the latest tag corresponding to that base_tag in both image and source repos. 
The results are compared and sent to a DB for analysis. It works for all images except Ironbank and quay.
"""

from datetime import datetime
import logging
import os
import re
import sys

import dateutil.parser
import requests
import yaml

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

class ImageTagsCheckHelper:
    """ A helper class for checking image tags """

    def __init__(self) -> None:
        self.docherhub_username = os.environ.get("DOCKERHUB_USERNAME")
        self.dockerhub_password = os.environ.get("DOCKERHUB_PASSWORD")
        self.image_list_file = "image.lst"
        self.script_path = os.path.dirname(os.path.abspath(__file__))
        self.image_list_file_path = os.path.join(self.script_path, "..", self.image_list_file)
        self._dockerhub_auth_token = self._get_auth_token()

    def _get_auth_token(self):
        """
        Retrieves the authentication token from the Docker Hub API.
        """
        url = "https://hub.docker.com/v2/users/login"
        data = {
            "username": self.docherhub_username,
            "password": self.dockerhub_password
        }
        try:
            response = requests.post(url, json=data, timeout=10)
            response.raise_for_status()  # Raise HTTPError for non-2xx status codes
            token = response.json()["token"]
            logging.info("Fetched Auth Token from Dockerhub API 🗝️\n")
            return token
        except requests.RequestException as e:
            raise requests.RequestException(f"Failed to make request to Docker Hub API: {e}\n")

    @staticmethod
    def read_yml_from_path(yml_file_path):
        """
        Reads a YAML file from the given file path and returns its contents as a dictionary.
        """
        try:
            with open(yml_file_path, "r", encoding="utf8") as yml_stream:
                yml_dict = yaml.safe_load(yml_stream)
                return yml_dict
        except yaml.YAMLError as exc:
            logging.error("Cannot fetch image_dict from image.yml")
            logging.error(exc)
            return {}

    def get_latest_tag_from_base_tag(self, account, repo, search_str):
        """
        Find the latest tag using search_str and return it along with its release timestamp"
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
            # timestamp = datetime.strptime(tags[-1]["tag_last_pushed"], "%Y-%m-%dT%H:%M:%S.%fZ")
            # timestamp_formatted = timestamp.strftime("%Y-%m-%d %H:%M:%S")
            return tags[-1]["name"], tags[-1]["tag_last_pushed"]
        return None, None

    def _fetch_tags(self, account, repo, deep = False):
        """
        Get tags from the dockerhub API
        """
        tags = []
        if deep:
            logging.info("Trying Deep Search")

        url = f"https://hub.docker.com/v2/repositories/{account}/{repo}/tags?page_size=100"
        while url:
            headers = {"Authorization": f"Bearer {self._dockerhub_auth_token}"}
            resp = requests.get(url, headers=headers, timeout=60)
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

    # pylint: disable=too-many-locals, too-many-branches
    def run_tags_check(self):
        """
        Runs the tag check for the images.

        This function reads the image list file and checks the tags for each image.
        It retrieves the latest tags for the source image and the hardened image,
        compares them, and determines if the tags are supported or unsupported.
        The results are then sent to a database for further analysis.

        Returns:
            None
        """
        unsupported_images = {}
        with open(self.image_list_file_path, "r", encoding="utf8") as stream:
            for image_path in stream.readlines():
                image_path = image_path.strip()

                unsupported_tags = []
                payload_for_db_request = []

                # all images except ironbank and quay are supported
                if image_path.strip().split("/")[-1] in {"ironbank", "quay"}:
                    continue

                logging.info(f"🏁 Starting Tag Check for Image: {image_path} 🏁")

                # reading image.yml for image name and account
                image_yml_path = os.path.join(self.script_path, "..",
                                                "community_images", image_path, "image.yml")
                image_dict = self.read_yml_from_path(image_yml_path)

                # getting source image account and name
                source_image_repo_link = image_dict.get("source_image_repo_link")
                if "/_/" in source_image_repo_link:
                    source_image_name = source_image_repo_link.split("/")[-1]
                    source_image_account = "library"
                elif "/r/" in source_image_repo_link:
                    source_image_account, source_image_name = source_image_repo_link.split("/")[-2:]

                # getting hardened image account and name
                hardened_image_account = "rapidfort"
                hardened_image_name = image_dict.get("rf_docker_link").split("/")[-1]

                # searching and comparing tags for every base tag
                if "repo_sets" not in image_dict:
                    logging.warning("！ Missing 'repo_sets' key in image_dict ！\n")
                    continue

                input_base_tags = [item[source_image_name]["input_base_tag"] for item in image_dict["repo_sets"]]
                for base_tag in input_base_tags:
                    logging.info(f"🏷️  Checking for base tag: '{base_tag}'")
                    latest_source_tag, source_release_timestamp = self.get_latest_tag_from_base_tag(source_image_account, source_image_name, base_tag)
                    latest_hardened_tag, _ = self.get_latest_tag_from_base_tag(hardened_image_account, hardened_image_name, base_tag)

                    logging.info(f"Latest Source Tag: {latest_source_tag}")
                    logging.info(f"Latest Hardened Tag: {latest_hardened_tag}")

                    days_since_release = 0  # Defaults to 0 for supported tags
                    if latest_source_tag != latest_hardened_tag:
                        logging.warning("Not Matched ❌")
                        if not source_release_timestamp:
                            logging.error(f"Source Release Timestamp is missing for base tag: {base_tag}")
                            continue

                        release_timestamp = datetime.strptime(source_release_timestamp, "%Y-%m-%dT%H:%M:%S.%fZ")
                        current_timestamp = datetime.now()
                        days_since_release = (current_timestamp - release_timestamp).days

                        unsupported_tags.append((latest_source_tag, days_since_release))
                    else:
                        logging.info("Matched ✅")
                    logging.info(f"Unsupported Since: {days_since_release} days")

                    payload_for_db_request.append({
                        "image_repo": image_path,
                        "base_tag": base_tag,
                        "latest_source_tag": latest_source_tag,
                        "release_timestamp": source_release_timestamp,
                        "unsupported_since_days": days_since_release
                    })

                # sending data to database for every image_path/image_repo
                url = "https://data-receiver.rapidfort.com/unsupported_image_tags"
                try:
                    headers = {
                        "Authorization": f"Bearer {os.environ.get('PULL_COUNTER_MAGIC_TOKEN')}"
                    }
                    response = requests.post(url, json=payload_for_db_request, headers=headers, timeout=10)
                    response.raise_for_status()  # Raise HTTPError for non-2xx status codes
                    logging.info(f"Successfully sent data for {image_path} to database\n")
                except requests.RequestException as e:
                    logging.error(f"Failed to send data for {image_path} to the database: {e}\n")

                # if there are unsupported tags for a particular image, we add that to list of unsupported images
                if unsupported_tags:
                    unsupported_images[image_path] = tuple(unsupported_tags)

        if unsupported_images:
            logging.warning("🚨 The Following Image Repos have Unsupported Tags: 🚨")
            for key, value in unsupported_images.items():
                print()
                logging.warning(f"Image: {key}")
                for tag, days in value:
                    logging.warning(f"    Tag: '{tag}' -> Unsupported Since: {days} days")
            logging.error("Some Image Repos have Unsupported Tags")
            sys.exit(1)
        logging.info("✅ Script Executed Successfully! All Image Repos have Supported Tags ✅")

def main():
    """ main function """
    logging.info("### This script fetches the latest tags for each image in image.lst and compares them between the image and source repositories. The results are sent to a database for analysis. ###")
    logging.info("### It performs checks for all the images except Ironbank and quay. ###\n")
    itch = ImageTagsCheckHelper()
    itch.run_tags_check()

if __name__ == "__main__":
    main()
