"""
This file is used by helpers script to fetch, sort and find
latest tag from a given image repo and search string
"""
import sys
import requests


def fetch_tags(image_repo):
    """
    Get tags from the dockerhub registry API
    """
    tags=[]

    # Handle official repository here
    if image_repo.startswith("_/"):
        image_repo=image_repo[2:]

    resp = requests.get(f"https://registry.hub.docker.com/v1/repositories/{image_repo}/tags")
    tags = resp;
    if 200 <= resp.status_code < 300:
        tag_objs = resp.json()
        tags = map(lambda x: x.get("name", ""), tag_objs)
    return tags


def get_latest_tag(tags, search_str):
    """
    Find latest tags using search_str"
    """
    search_str_len = len(search_str)

    tags = filter(lambda tag: search_str in tag, tags)
    tags = list(filter(
        lambda tag: "rfstub" not in tag and tag[search_str_len:].rstrip().isdigit(),
        tags))
    if len(tags)==0:
        return []

    tags.sort(key = lambda tag: int(tag[search_str_len:]))
    if tags:
        return tags[-1]
    return []


def main():
    """Main function to sort and find latest tags"""

    if len(sys.argv) != 3:
        print("Usage latest_tag <image_repo:bitnami/redis> <search_string>")
        sys.exit(1)

    image_repo = sys.argv[1]
    search_str = sys.argv[2]

    tags = fetch_tags(image_repo)
    latest_tag = get_latest_tag(tags, search_str)
    if latest_tag:
        print(latest_tag)


if __name__ == "__main__":
    main()
