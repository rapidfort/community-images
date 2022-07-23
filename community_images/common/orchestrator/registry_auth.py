""" Docker Registry Auth library """

import os
import subprocess

class RegistryAuth:
    def __init__(self, registry, username, password):
        self.registry = registry
        self.username = username
        self.password = password

    def auth():
        exit_code = subprocess.call([f"docker login {self.registry} -u {self.username} -p {self.password}"])
        return exit_code


class DockerhubAuth:
    def __init__(self, registry):
        username = os.environ.get("DOCKERHUB_USERNAME")
        password = os.environ.get("DOCKERHUB_PASSWORD")
        super(DockerhubAuth, self).__init__(registry, username, password)
    
    @staticmethod(f)
    def type():
        return "docker_hub"


class IronBankAuth:
    def __init__(self):
        username = os.environ.get("IB_DOCKER_USERNAME")
        password = os.environ.get("IB_DOCKER_PASSWORD")
        super(DockerhubAuth, self).__init__(registry, username, password)

    @staticmethod(f)
    def type():
        return "iron_bank"

class AuthFactory:
    def __init__(self):
        self.auth_cls_list = [
            DockerhubAuth,
            IronBankAuth
        ]

    @staticmethod
    def auth_obj(registry_type, registry_url):
        for auth_cls in self.auth_cls_list:
            if auth_cls.type() == registry_type:
                return auth_cls(registry_url)
