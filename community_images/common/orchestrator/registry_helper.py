""" Docker Registry Helper library """

import os
import subprocess

class RegistryHelper(object):
    def __init__(self, registry, username, password):
        self.registry = registry
        self.username = username
        self.password = password

    def auth(self):
        exit_code = 0#subprocess.call([f"docker login {self.registry} -u {self.username} -p {self.password}"])
        return exit_code


class DockerHubHelper(RegistryHelper):
    def __init__(self, registry):
        username = os.environ.get("DOCKERHUB_USERNAME")
        password = os.environ.get("DOCKERHUB_PASSWORD")
        super(DockerHubHelper, self).__init__(registry, username, password)
    
    @staticmethod
    def registry_url():
        return "docker.io"


class IronBankHelper(RegistryHelper):
    def __init__(self):
        username = os.environ.get("IB_DOCKER_USERNAME")
        password = os.environ.get("IB_DOCKER_PASSWORD")
        super(IronBankHelper, self).__init__(registry, username, password)

    @staticmethod
    def registry_url():
        return "registry1.dso.mil"

class RegistryFactory:
    REGISTRY_HELPER_CLS_LIST = [
        DockerHubHelper,
        IronBankHelper
    ]

    @classmethod
    def reg_helper_obj(cls, registry_url):
        for reg_cls in cls.REGISTRY_HELPER_CLS_LIST:
            if reg_cls.registry_url() == registry_url:
                return reg_cls(registry_url)
