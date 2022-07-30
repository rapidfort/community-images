""" Docker setup module """

import logging
import os
import time

class DockerSetup:
    """ Docker setup context manager """
    def __init__(self, namespace_name, release_name, image_tag_list, runtime_props, image_script_dir):
        self.namespace_name = namespace_name
        self.release_name = release_name
        self.image_tag_list = image_tag_list
        self.runtime_props = runtime_props
        self.image_script_dir = image_script_dir
        self.script_dir = os.path.abspath(os.path.dirname( __file__ ))

    def __enter__(self):
        """ create a docker namespace and set it up for runner """
        # create network
        cmd=f"docker network create -d bridge {self.namespace_name}"
        subprocess.check_output(cmd.split())

        # create docker container
        cmd=f"docker run --rm -d --network={self.namespace_name}"
        cmd+=f" --name {self.namespace_name}"
        cmd+=f" $IMAGE_REPOSITORY:latest" #fixme
        subprocess.check_output(cmd.split())

        # sleep for few seconds
        time.sleep(30)

    def __exit__(self, type, value, traceback):
        """ delete docker namespace """
        # clean up docker container
        cmd=f"docker kill {self.namespace_name}"
        subprocess.check_output(cmd.split())

        # delete network
        cmd=f"docker network rm {self.namespace_name}"
        subprocess.check_output(cmd.split())
