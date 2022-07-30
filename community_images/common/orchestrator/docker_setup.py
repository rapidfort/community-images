""" Docker setup module """

import logging
import os


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

    def __exit__(self, type, value, traceback):
        """ delete docker namespace """
