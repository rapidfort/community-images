""" Generates stub """
from registry_auth import AuthFactory
 
class StubGenerator:
    def __init__(self, config_dict):
        self.config_dict = config_dict

    def generate(self):
        repos = self.config_dict.get("repos", [])
        input_registry = self.config_dict.get("input_registry")
        input_registry_url = input_registry.get("registry")
        input_repo_auth = AuthFactory.auth_obj(input_registry_url)

        input_repo_auth.auth()

        for repo in repos:
            input_repo = repo.get("input_repo")
            input_base_tags = repo.get("input_base_tags", [])
            output_repo = repo.get("output_repo")


            for tag in input_base_tags:
                pass