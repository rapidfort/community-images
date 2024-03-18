import logging
import os

import requests
import yaml

class ImageTagsCheckHelper:
    def __init__(self) -> None:
        self.docherhub_username = "phull.kanav@gmail.com"
        self.dockerhub_password = "----"
        self.image_list_file = "image.lst"
        self.script_path = os.path.dirname(os.path.abspath(__file__))
        self._dockerhub_auth_token = self._get_dockerhub_auth_token()
        self._ironbank_auth_token = self._get_ironbank_auth_token()

    def _get_dockerhub_auth_token(self):
        url = "https://hub.docker.com//v2/users/login"
        data = {
            "username": self.docherhub_username,
            "password": self.dockerhub_password
        }
        response = requests.post(url, json=data)
        if response.status_code == 200:
            return response.json()["token"]
        else:
            raise Exception("Failed to authenticate with Docker Hub API")

    def _get_ironbank_auth_token(self):
        # TODO: implement this
        return ""

    @staticmethod
    def parse_tags_from_dockerhub_api_response(response):
        tags = []
        for tag in response.json()['results']:
            # omitting the latest tag
            if tag['name'] != "latest":
                tags.append(tag['name'])
        return tags
    
    def _fetch_dockerhub_image_tags(self, image_name, repo, image_path):
        url = f"https://hub.docker.com/v2/repositories/{repo}/{image_name}/tags?page=1&page_size=11"
        headers = {"Authorization": f"Bearer {self._dockerhub_auth_token}"}

        response = requests.get(url, headers=headers)
        if response.status_code == 200:
            source_image_tags = self.parse_tags_from_dockerhub_api_response(response)
            return source_image_tags
        else:
            print(f"Failed to fetch tags for {image_path}. Status code: {response.status_code} \n Response: {response.text}")
            return None
            
    def run_tags_check(self):
        image_list_file_path = os.path.join(self.script_path, "..", self.image_list_file)
        with open(image_list_file_path, "r", encoding="utf8") as stream:
            for image_path in stream.readlines():
                image_path_arr = image_path.split("/")
                if image_path_arr[-1] != "ironbank":
                    # dockerhub image
                    if len(image_path_arr) != 2:
                        # TODO: Handle airflow images separately
                        print("Invalid image path")
                        return None
                    
                    if image_path_arr[-1] == "bitnami":
                        source_image_name = f"{image_path_arr[0]}"
                        source_image_repo = "bitnami"
                    elif image_path_arr[-1] == "official":
                        source_image_name = image_path_arr[0]
                        source_image_repo = "library"
                    
                    source_image_tags = self._fetch_dockerhub_image_tags(source_image_name, source_image_repo, image_path)
                    
                    # now fetching tags for hardened image
                    image_yml_path = os.path.join(self.script_path, "..", "community_images", image_path, "image.yml")
                    try:
                        with open(image_yml_path, "r", encoding="utf8") as yml_stream:
                            image_dict = yaml.safe_load(yml_stream)
                            hardened_image_repo_name = image_dict.get("rf_docker_link")
                    except yaml.YAMLError as exc:
                        print("Cannot fetch hardened image repo name")
                        logging.error(exc)
                    
                    hardened_image_tags = self._fetch_dockerhub_image_tags(hardened_image_repo_name, image_path)

                    # tag matching logic checks if we have atleast one tag matching for source and hardened image
                    one_tag_matches = False
                    hardened_image_tags_set = set(hardened_image_tags)
                    for tag in source_image_tags:
                        if tag in hardened_image_tags_set:
                            print(f"Tag {tag} for image {image_path} found in hardened image")
                            one_tag_matches = True
                            break
                    if not one_tag_matches:
                        # TODO: Raise Alert
                        print(f"No tags found in hardened image for image {image_path}")
                    
                else:
                    # TODO: implement logic for ironbank images
                    pass

def main():
    """ main function """
    itch = ImageTagsCheckHelper()

if __name__ == "__main__":
    main()
