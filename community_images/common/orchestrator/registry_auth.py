""" Docker Registry Auth library """

import os
import subprocess

class RegistryAuth(object):
    def __init__(self, registry, username, password):
        self.registry = registry
        self.username = username
        self.password = password

    def auth(self):
        exit_code = subprocess.call([f"docker login {self.registry} -u {self.username} -p {self.password}"])
        return exit_code


class DockerhubAuth(RegistryAuth):
    def __init__(self, registry):
        username = os.environ.get("DOCKERHUB_USERNAME")
        password = os.environ.get("DOCKERHUB_PASSWORD")
        super(DockerhubAuth, self).__init__(registry, username, password)
    
    @staticmethod
    def registry_url():
        return "docker.io"


class IronBankAuth(RegistryAuth):
    def __init__(self):
        username = os.environ.get("IB_DOCKER_USERNAME")
        password = os.environ.get("IB_DOCKER_PASSWORD")
        super(IronBankAuth, self).__init__(registry, username, password)

    @staticmethod
    def registry_url():
        return "registry1.dso.mil"

class AuthFactory:
    AUTH_CLS_LIST = [
        DockerhubAuth,
        IronBankAuth
    ]

    @classmethod
    def auth_obj(cls, registry_url):
        for auth_cls in cls.AUTH_CLS_LIST:
            if auth_cls.registry_url() == registry_url:
                return auth_cls(registry_url)
