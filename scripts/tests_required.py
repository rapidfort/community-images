""" Script to check if github actions test is required """
import os
import sys
import logging
import requests


def get_pull_number():
    """ Get pull number """
    github_ref = os.environ.get('GITHUB_REF')
    logging.info(f"{github_ref}")

    ref_part = github_ref.split('/')
    if len(ref_part) != 4:
        return -1

    pull_number = ref_part[2]
    return pull_number

def get_list_of_files(pull_number):
    """ Get list of files in PR """
    github_token = os.environ.get("GITHUB_TOKEN")
    endpoint = "https://api.github.com"
    url = f"{endpoint}/repos/rapidfort/community-images"
    url += f"/pulls/{pull_number}/files"

    headers = {"Authorization" : f"Bearer {github_token}"}
    resp = requests.get(url, headers=headers, timeout=60)
    list_of_files = []
    if resp.status_code == 200:
        list_of_files = map(lambda x:x.get("filename"), resp.json())
    else:
        logging.error(resp.text)
    return list_of_files


def check_if_tests_required(image_name, image_github_location):
    """ Check if tests required """
    logging.info(f"Image name={image_name}")

    pull_number = get_pull_number()
    logging.info(f"Pull number={pull_number}")

    list_of_files = list(get_list_of_files(pull_number))
    logging.info(f"List of files={list_of_files}")

    path_of_image = f"community_images/{image_github_location}/"

    logging.info(f"Path of image {path_of_image}")

    for updated_file in list_of_files:
        logging.info(f"Testing {updated_file}")

        # Test for files in the folder
        if updated_file.startswith(path_of_image):
            logging.info(f"Found file with changes {updated_file}")
            return True

        # Test for orchestrator changes with few random tests
        if (updated_file.startswith("community_images/common/orchestrator/") or
                updated_file.startswith("community_images/common/tests/")):
            if image_name in ["curl", "nginx-ib", "redis", "postgresql-ib", "mongodb", "mysql"]:
                logging.info(f"Picking tests for orchestrator and tests {updated_file}")
                return True

        # Test for changes in scripts folder
        if (updated_file.startswith("scripts/") or
                updated_file.startswith("community_images/common/templates")):
            if image_name in ["curl"]:
                logging.info(f"Picking curl test for script changes {updated_file}")
                return True

    logging.info("Not found match, returning False")
    return False


def output_test_required(output_file, tests_required):
    """ Create output file for tests required """
    test_req_str = "yes" if tests_required else "no"
    with open(output_file, "w", encoding="utf8") as out_fp:
        out_fp.write(f"TEST_REQUIRED={test_req_str}")


def main():
    """ Main function """
    logging.basicConfig(level=logging.DEBUG)

    logging.info(sys.argv)
    if len(sys.argv) != 4:
        logging.error("Usage: python3 scripts/tests_required.py <image.name> <image.github_location> <output.txt>")
        sys.exit(1)

    image_name = sys.argv[1]
    image_github_location = sys.argv[2]
    output_file = sys.argv[3]
    tests_required = check_if_tests_required(image_name, image_github_location)
    output_test_required(output_file, tests_required)


if __name__ == "__main__":
    main()
