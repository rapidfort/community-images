""" Script to check if github actions test is required """
import os
import requests
import sys
import logging


def get_pull_number():
    github_ref = os.environ.get('GITHUB_REF')
    logging.info(f"{github_ref}")

    ref_part = github_ref.split('/')
    if len(ref_part) != 4:
        return -1

    pull_number = ref_part[2]
    logging.info(f"Pull number={pull_number}")
    return pull_number

def get_list_of_files(pull_number):
    """ Get list of files in PR """
    github_token = os.environ.get("GITHUB_TOKEN")
    endpoint = "https://api.github.com"
    url = f"{endpoint}/repos/rapidfort/community-images"
    url += f"/pulls/{pull_number}/files"

    headers = {"Authorization" : f"Bearer {github_token}"}
    resp = requests.get(url, headers=headers)
    if resp.status_code == 200:
        logging.info(resp.text)
    else:
        logging.error(resp.text)

def check_if_tests_required(image_name):
    """ Check if tests required """
    pull_number = get_pull_number()
    logging.info(f"Pull number={pull_number}")
    logging.info(f"Image name={image_name}")

    list_of_files = get_list_of_files(pull_number)

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
    if len(sys.argv) != 3:
        sys.exit(1)

    image_name = sys.argv[1]
    output_file = sys.argv[2]
    tests_required = check_if_tests_required(image_name)
    output_test_required(output_file, tests_required)


if __name__ == "__main__":
    main()
