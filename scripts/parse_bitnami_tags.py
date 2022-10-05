import requests
import json
url = "https://raw.githubusercontent.com/bitnami/containers/main/bitnami/envoy/README.md"
import re
r=requests.get(url)

docker_lines = []
for line in r.text.split('\n'):
    if "/Dockerfile" in line:
        docker_lines.append(line[2:])


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
        print(abs_tag[:rloc+2])


