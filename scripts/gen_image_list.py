"""
This python script generates an array of image.yml files
This is consumed by jinja template for generating main readme
"""

import os
import yaml


def merge_yaml_files():
    """
    Reads image.lst file
    Opens image.yml for each image
    Creates an array with all image.yml content
    Dumps to image_list.yml at repo root
    """
    script_path = os.path.dirname(os.path.abspath(__file__))
    image_lst_path = os.path.join(script_path, "..", "image.lst")
    image_list = []
    with open(image_lst_path, "r", encoding="utf8") as stream:
        for image_path in stream.readlines():
            image_yml_path = os.path.join(
                script_path,
                "..",
                "community_images",
                image_path.rstrip(),
                "image.yml")
            try:
                with open(image_yml_path, "r", encoding="utf8") as image_yml_stream:
                    image_dict = yaml.safe_load(image_yml_stream)
                    image_list.append(image_dict)
            except yaml.YAMLError as exc:
                print(exc)
    image_list_dict = dict(image_list=image_list)

    out_yml_path = os.path.join(script_path, "..", "image_list.yml")
    with open(out_yml_path, "w", encoding="utf8") as outfile:
        yaml.dump(image_list_dict, outfile, default_flow_style=False)


if __name__ == "__main__":
    merge_yaml_files()
