import logging
import os
import sys

import requests
import yaml

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

class ImageTagsCheckHelper:
    def __init__(self) -> None:
        self.docherhub_username = os.environ.get("DOCKERHUB_USERNAME")
        self.dockerhub_password = os.environ.get("DOCKERHUB_PASSWORD")
        self.image_list_file = "image.lst"
        self.script_path = os.path.dirname(os.path.abspath(__file__))
        self._dockerhub_auth_token = self._get_auth_token()

    def _get_auth_token(self):
        url = "https://hub.docker.com//v2/users/login"
        data = {
            "username": self.docherhub_username,
            "password": self.dockerhub_password
        }
        response = requests.post(url, json=data)
        if response.status_code == 200:
            logging.info("Fetched Auth Token from Dockerhub API 🗝️")
            return response.json()["token"]
        else:
            raise Exception("Failed to authenticate with Docker Hub API")

    @staticmethod
    def parse_tags_from_api_response(response):
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
        url = f"https://hub.docker.com/v2/repositories/{repo}/{image_name}/tags?page=1&page_size=11"
        headers = {"Authorization": f"Bearer {self._dockerhub_auth_token}"}

        response = requests.get(url, headers=headers)
        if response.status_code == 200:
            source_image_tags = self.parse_tags_from_api_response(response)
            return source_image_tags
        else:
            logging.error(f"Failed to fetch tags for {image_path}. Status code: {response.status_code}")
            return None
            
    def run_tags_check(self):
        failed_images = []
        image_list_file_path = os.path.join(self.script_path, "..", self.image_list_file)
        with open(image_list_file_path, "r", encoding="utf8") as stream:
            for image_path in stream.readlines():
                image_path = image_path.strip()
                image_path_arr = image_path.strip().split("/")
                # all images except ironbank ones are supported
                if image_path_arr[-1] != "ironbank":
                    logging.info(f"Starting Tag Check for Image: {image_path}")
                    
                    # reading image.yml for image name and repo
                    image_yml_path = os.path.join(self.script_path, "..", "community_images", image_path, "image.yml")
                    try:
                        with open(image_yml_path, "r", encoding="utf8") as yml_stream:
                            # this image_dict is later used to extract image name and repo for both source and hardened image
                            image_dict = yaml.safe_load(yml_stream)
                    except yaml.YAMLError as exc:
                        logging.error("Cannot fetch image_dict from image.yml")
                        logging.error(exc)

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
                    common_count = 0
                    hardened_image_tags_set = set(hardened_image_tags)
                    for tag in source_image_tags:
                        if tag in hardened_image_tags_set:
                            logging.info(f"Tag '{tag}' matches for image {image_path}")
                            common_count += 1
                            if common_count >= 2:
                                break
                    if common_count < 2:
                        logging.warning(f"🚨 No tags match for image {image_path} 🚨\n")
                        failed_images.append(image_path)
                    else:
                        logging.info(f"{image_path} is supported ✅\n\n")

        if failed_images:
            logging.warning("🚨🚨🚨 No common tags found between the source and hardened image for the following images: 🚨🚨🚨")
            for image in failed_images:
                logging.info(image)
            logging.warning("Error: Some Images are not supported")
            sys.exit(1)
        else:
            logging.info("✅✅ Script Executed Successfully! All images are supported! ✅✅")

def main():
    """ main function """
    logging.info("### This workflow script fetches top 10 tags for source image and hardened image and checks if atleast two tags match ###")
    logging.info("### It performs checks for all the images except Ironbank ones. ###\n")
    itch = ImageTagsCheckHelper()
    itch.run_tags_check()

if __name__ == "__main__":
    main()
