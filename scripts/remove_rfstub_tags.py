""" Helper script to delete rfstub tags """
import logging
import os
import time
import docker
import requests
import yaml

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
        """ registry url """
        return "docker.io"

    def get_rfstub_tag(self, account, repo):
        """
        Find rfstub tags using search_str
        """
        tags = self._fetch_tags(account, repo)
        tags = list(filter(
            lambda tag: "rfstub" in tag["name"],
            tags))

        return map(lambda x:x.get("name"), tags)

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
        """ delete tags """
        del_url = f"{self.BASE_URL}/v2/repositories/{account}/{repo}/tags/{tag}/"
        auth_header = self.get_auth_header()
        resp = requests.delete(del_url, headers=auth_header, timeout=30)
        print(resp.status_code, resp.text, del_url)
        time.sleep(0.1)
        return resp.status_code == 200

def generate_image_names_list():
    """ Generate image names list """
    base_dir = 'community_images'
    image_list_file = 'image.lst'
    output_file = 'image_names.lst'

    image_names = []

    with open(image_list_file, 'r', encoding='utf-8') as file:
        directories = file.readlines()

    for directory in directories:
        directory = directory.strip()
        image_yml_path = os.path.join(base_dir, directory, 'image.yml')

        if os.path.exists(image_yml_path):
            try:
                with open(image_yml_path, 'r', encoding='utf-8') as yml_file:
                    data = yaml.safe_load(yml_file)

                name = data.get('name')

                if name:
                    image_names.append(name)
            except yaml.YAMLError as exc:
                print(f"Error parsing {image_yml_path}: {exc}")

    with open(output_file, 'w', encoding='utf-8') as out_file:
        for name in image_names:
            out_file.write(f"{name}\n")

    print(f"Generated {output_file} with {len(image_names)} entries.")
    return image_names, output_file

if __name__ == "__main__":
    # Generate the image_names.lst file and get the list of image names
    repos_to_del, generated_file = generate_image_names_list()

    dc = docker.from_env()
    dh = DockerHubHelper(dc)

    # Delete the corresponding stub tags from dockerhub
    for repo_to_del in repos_to_del:
        del_tags = dh.get_rfstub_tag("rapidfort", repo_to_del)
        for del_tag in del_tags:
            dh.delete_tag("rapidfort", repo_to_del, del_tag)

    # Delete the generated file
    if os.path.exists(generated_file):
        os.remove(generated_file)
        print(f"Deleted temporary file: {generated_file}")
