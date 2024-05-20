""" 
This script fetches the top 10 tags for source and hardened images 
for all images in image.lst (except the Ironbank ones), and checks 
if atleast two tags match.
It logs a list of images for which < 2 tags match and exits with an 
error code if any such image is found.
"""

import logging
import os
import sys

import requests
import yaml

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

class ImageTagsCheckHelper:
    """
    Helper class for checking image tags between source and hardened images.

    Attributes:
        docherhub_username (str): The Docker Hub username.
        dockerhub_password (str): The Docker Hub password.
        image_list_file (str): The file containing the list of images to check.
        script_path (str): The path of the script file.
        _dockerhub_auth_token (str): The authentication token for Docker Hub API.

    Methods:
        _get_auth_token(): Fetches the authentication token from Docker Hub API.
        parse_tags_from_api_response(response): Parses the tags from the API response.
        _fetch_image_tags(image_name, repo, image_path): Fetches the tags for a specific image.
        run_tags_check(): Runs the tag check for all images in the image list file.
    """

    def __init__(self) -> None:
        self.docherhub_username = os.environ.get("DOCKERHUB_USERNAME")
        self.dockerhub_password = os.environ.get("DOCKERHUB_PASSWORD")
        self.image_list_file = "image.lst"
        self.script_path = os.path.dirname(os.path.abspath(__file__))
        self.image_list_file_path = os.path.join(self.script_path, "..", self.image_list_file)
        self._dockerhub_auth_token = self._get_auth_token()

    def _get_auth_token(self):
        """
        Fetches the authentication token from Docker Hub API.

        Returns:
            str: The authentication token.
        
        Raises:
            Exception: If failed to authenticate with Docker Hub API.
        """
        url = "https://hub.docker.com//v2/users/login"
        data = {
            "username": self.docherhub_username,
            "password": self.dockerhub_password
        }
        try:
            response = requests.post(url, json=data, timeout=10)
            response.raise_for_status()  # Raise HTTPError for non-2xx status codes
            token = response.json()["token"]
            logging.info("Fetched Auth Token from Dockerhub API 🗝️")
            return token
        except requests.RequestException as e:
            raise requests.RequestException(f"Failed to make request to Docker Hub API: {e}")

    @staticmethod
    def parse_tags_from_api_response(response):
        """
        Parses the tags from the Dockerhub API response.

        Args:
            response (Response): The API response object.

        Returns:
            list: The list of tags parsed from the response.
        """
        tags = []
        try:
            for tag in response.json()['results']:
                # omitting the latest tag
                if tag['name'] != "latest":
                    tags.append(tag['name'])
            return tags
        except KeyError:
            logging.error("！Failed to parse tags from API response ！")
            return []

    def _fetch_image_tags(self, image_name, repo, image_path):
        """
        Fetches the tags for a specific image.

        Args:
            image_name (str): The name of the image.
            repo (str): The repository of the image.
            image_path (str): The path of the image.

        Returns:
            list: The list of tags for the image.
        """
        url = f"https://hub.docker.com/v2/repositories/{repo}/{image_name}/tags?page=1&page_size=11"
        headers = {"Authorization": f"Bearer {self._dockerhub_auth_token}"}

        try:
            response = requests.get(url, headers=headers, timeout=10)
            response.raise_for_status()  # Raise HTTPError for non-2xx status codes
            if response.status_code == 200:
                source_image_tags = self.parse_tags_from_api_response(response)
                return source_image_tags
            logging.error("Failed to fetch tags for %s. Status code: %d", image_path, response.status_code)
            return None
        except requests.RequestException as e:
            logging.error(f"Failed to fetch tags for {image_path}: {e}")
            return None

    @staticmethod
    def match_tags(source_image_tags, hardened_image_tags, image_path):
        """
        Checks if there are common tags between the source image tags and the hardened image tags.

        Args:
            source_image_tags (list): The tags of the source image.
            hardened_image_tags (list): The tags of the hardened image.

        Returns:
            bool: True if there are at least 2 common tags, False otherwise.
        """
        common_count = 0
        hardened_image_tags_set = set(hardened_image_tags)
        for tag in source_image_tags:
            if tag in hardened_image_tags_set:
                logging.info(f"Tag '{tag}' matches for image {image_path}")
                common_count += 1

        # The value set to 2 can be changed according to the strictness required for tag matching.
        return common_count >= 2

    @staticmethod
    def read_yml_from_path(yml_file_path):
        """
        Reads a YAML file from the given file path and returns the parsed YAML data as a dictionary.

        Args:
            yml_file_path (str): The path to the YAML file.

        Returns:
            dict: A dictionary containing the parsed YAML data.
        """
        try:
            with open(yml_file_path, "r", encoding="utf8") as yml_stream:
                yml_dict = yaml.safe_load(yml_stream)
                return yml_dict
        except yaml.YAMLError as exc:
            logging.error("Cannot fetch image_dict from image.yml")
            logging.error(exc)
            return {}

    def run_tags_check(self):
        """
        Runs the tag check for all images in the image list file.
        """
        failed_images = []
        source_image_name = None
        source_image_repo = None
        with open(self.image_list_file_path, "r", encoding="utf8") as stream:
            for image_path in stream.readlines():
                image_path = image_path.strip()
                # all images except ironbank ones are supported
                if image_path.strip().split("/")[-1] != "ironbank":
                    logging.info(f"Starting Tag Check for Image: {image_path}")

                    # reading image.yml for image name and repo
                    image_yml_path = os.path.join(self.script_path, "..",
                                                   "community_images", image_path, "image.yml")
                    image_dict = self.read_yml_from_path(image_yml_path)

                    source_image_repo_link = image_dict.get("source_image_repo_link")
                    if "/_/" in source_image_repo_link:
                        source_image_name = source_image_repo_link.split("/")[-1]
                        source_image_repo = "library"
                    elif "/r/" in source_image_repo_link:
                        source_image_repo, source_image_name = source_image_repo_link.split("/")[-2:]

                    logging.info(f"Fetching tags for image: '{source_image_name}' from repo: '{source_image_repo}'")
                    source_image_tags = self._fetch_image_tags(source_image_name, source_image_repo, image_path)

                    # now fetching tags for hardened image
                    hardened_image_repo = "rapidfort"

                    rf_docker_link = image_dict.get("rf_docker_link")
                    hardened_image_name = rf_docker_link.split("/")[-1]

                    logging.info(f"Fetching tags for hardened image: '{hardened_image_name}' from repo: '{hardened_image_repo}'")
                    hardened_image_tags = self._fetch_image_tags(hardened_image_name, hardened_image_repo, image_path)

                    # tag matching logic checks if we have atleast two tag matching for source and hardened image
                    logging.info("Matching Tags ...")
                    if self.match_tags(source_image_tags, hardened_image_tags, image_path) is False:
                        logging.warning(f"🚨 {image_path} image is not supported 🚨\n")
                        failed_images.append(image_path)
                    else:
                        logging.info(f"{image_path} is supported ✅\n\n")

        if failed_images:
            logging.warning("🚨🚨🚨 The following images are not supported: 🚨🚨🚨")
            for image in failed_images:
                logging.info(image)
            logging.warning("Error: Some Images are not supported")
            sys.exit(1)
        logging.info("✅✅ Script Executed Successfully! All images are supported! ✅✅")

def main():
    """ main function """
    logging.info("### This workflow script fetches top 10 tags for source image and hardened image and checks if atleast two tags match ###")
    logging.info("### It performs checks for all the images except Ironbank ones. ###\n")
    itch = ImageTagsCheckHelper()
    itch.run_tags_check()

if __name__ == "__main__":
    main()
