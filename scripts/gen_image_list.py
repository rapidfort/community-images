"""
This python script generates an array of image.yml files
This is consumed by jinja template for generating main readme
"""

import os
import sys
import requests
import yaml

def get_image_dh_data(image_dict):
    """
    Get dockerhub data and push it to yaml
    input: image_dict
    output: image_dict
    """
    rf_docker_link = image_dict["rf_docker_link"]
    url = f"https://hub.docker.com/v2/repositories/{rf_docker_link}/"
    resp = requests.get(url, timeout=30)
    if 199 <= resp.status_code < 400:
        resp_json = resp.json()
        image_dict["pull_count"] = resp_json.get("pull_count")
        image_dict["last_updated"] = resp_json.get("last_updated")
        image_dict["star_count"] = resp_json.get("star_count")
        image_dict["pull_count_formatted"] = format(image_dict["pull_count"], ",")
        print(f"Got image data for {rf_docker_link}")
        print(f"p:{image_dict['pull_count']}, lu:{image_dict['last_updated']}, s:{image_dict['star_count']}")
    else:
        print("failed to get dh data [%d]: %s ", resp.status_code, resp.texts)
        sys.exit(1)
    return image_dict


def merge_yaml_files(image_list_file, needs_dh_data=False):
    """
    Reads image.lst file
    Opens image.yml for each image
    Creates an array with all image.yml content
    Dumps to image_list.yml at repo root
    """
    script_path = os.path.dirname(os.path.abspath(__file__))
    image_lst_path = os.path.join(script_path, "..", image_list_file)
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
                    if needs_dh_data:
                        image_dict = get_image_dh_data(image_dict)
                    image_list.append(image_dict)
            except yaml.YAMLError as exc:
                print(exc)
    image_list=sorted(image_list, key=lambda i: i["name"])
    if needs_dh_data:
        image_list_sorted = sorted(image_list, key=lambda i: i["pull_count"],reverse=True)
        image_list_dict = dict(image_list=image_list,image_list_sorted=image_list_sorted)
    else:
        image_list_dict = dict(image_list=image_list)

    out_yml_path = os.path.join(script_path, "..", "image_list.yml")
    with open(out_yml_path, "w", encoding="utf8") as outfile:
        yaml.dump(image_list_dict, outfile, default_flow_style=False)


def main():
    """ main function """
    image_list_file = "image.lst"
    if len(sys.argv) == 3:
        image_list_file = sys.argv[1]
        needs_dh_data = sys.argv[2]=="yes"

    print(f"Using image list={image_list_file}")
    merge_yaml_files(image_list_file, needs_dh_data)


if __name__ == "__main__":
    main()
