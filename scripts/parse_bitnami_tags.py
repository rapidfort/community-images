import re
import requests
import json


def get_docker_lines(container_name):
    url = "https://raw.githubusercontent.com/bitnami/"
    url += f"containers/main/bitnami/{container_name}/README.md"
    r=requests.get(url)
    docker_lines = []

    if 199 < r.status_code < 400:
        for line in r.text.split('\n'):
            if "/Dockerfile" in line:
                docker_lines.append(line[2:])
    return docker_lines

def get_input_base_tags(docker_lines):
    base_tags = []
    for dl in docker_lines:
        dl_search = re.search("\[(.*?)\]", dl)
        if dl_search:
            dl_array = f"[{dl_search.group(1)}]"
            dl_array = dl_array.replace('`','"')

            b1=dl_array.find("(")
            if b1:
                dl_array=f"{dl_array[:b1]}]"

            ar = json.loads(dl_array)
            abs_tag = ar[3]
            rloc = abs_tag.find("-r")
            base_tags.append(abs_tag[:rloc+2])
    return base_tags

dl = get_docker_lines("envoy")
print(dl)

bt = get_input_base_tags(dl)
print(bt)
