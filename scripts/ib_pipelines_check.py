"""
This script checks the status of the latest pipeline for multiple GitLab projects
and reports on the status of the rapidfort-scan job within those pipelines.
"""
import sys
import requests

# Configuration
GITLAB_BASE_URL = "https://repo1.dso.mil/api/v4"
FILE_PATH = "./scripts/ib_pipelines_list_links.lst"

FAILED_PIPELINES = []
NOT_FOUND_PIPELINES = []

def get_project_endpoint(link):
    """
    Generate the project API endpoint from the given link.

    Args:
        link (str): The project link.

    Returns:
        str: The project API endpoint.
    """
    project_path = link.split('dsop/')[1].replace('/pipelines', '').replace('/', '%2F')
    return f"projects/dsop%2F{project_path}/pipelines"

def get_latest_pipeline(endpoint):
    """
    Get the latest pipeline from the given project endpoint.

    Args:
        endpoint (str): The project API endpoint.

    Returns:
        dict or None: The latest pipeline or None if no pipeline is found.
    """
    url = f"{GITLAB_BASE_URL}/{endpoint}"
    response = requests.get(url, timeout=10)
    if response.status_code == 401:
        print(f"Unauthorized access to {url}. This project may require authentication.")
        return None
    response.raise_for_status()
    pipelines = response.json()
    if pipelines:
        return pipelines[0]
    return None

def get_jobs(endpoint, pipeline_id):
    """
    Get jobs from the specified pipeline.

    Args:
        endpoint (str): The project API endpoint.
        pipeline_id (int): The pipeline ID.

    Returns:
        list: The list of jobs in the pipeline.
    """
    url = f"{GITLAB_BASE_URL}/{endpoint}/{pipeline_id}/jobs"
    response = requests.get(url, timeout=10)
    if response.status_code == 401:
        print(f"Unauthorized access to {url}. This project may require authentication.")
        return []
    response.raise_for_status()
    return response.json()

def check_rapidfort_scan(jobs):
    """
    Check the status of the rapidfort-scan job.

    Args:
        jobs (list): The list of jobs in the pipeline.

    Returns:
        str: The status of the rapidfort-scan job or "not found" if the job does not exist.
    """
    for job in jobs:
        if job['name'] == 'rapidfort-scan':
            return job['status']
    return "not found"

def main():
    """
    Main function to read project links, check pipelines, and print the results.
    """
    with open(FILE_PATH, 'r', encoding='utf-8') as file:
        project_links = [line.strip() for line in file if line.strip()]
    for link in project_links:
        endpoint = get_project_endpoint(link)
        latest_pipeline = get_latest_pipeline(endpoint)
        if latest_pipeline:
            pipeline_id = latest_pipeline['id']
            pipeline_web_url = latest_pipeline['web_url']
            jobs = get_jobs(endpoint, pipeline_id)
            rf_scan_status = check_rapidfort_scan(jobs)
            print(f"Pipeline ID: {pipeline_id}\nURL: {pipeline_web_url}\nrapidfort-scan status: {rf_scan_status}")
            print("-" * 50)
            if rf_scan_status == 'failed':
                FAILED_PIPELINES.append(f"Pipeline ID: {pipeline_id}, URL: {pipeline_web_url}")
            elif rf_scan_status == 'not found':
                NOT_FOUND_PIPELINES.append(f"Pipeline ID: {pipeline_id}, URL: {pipeline_web_url}")
        else:
            print(f"No pipelines found for project endpoint: {endpoint}")
            print("-" * 50)
    # Print summary of failed pipelines
    print("Summary of Pipelines that Failed the rapidfort-scan:")
    if FAILED_PIPELINES:
        for failed_pipeline in FAILED_PIPELINES:
            print(failed_pipeline)
    else:
        print("No pipelines failed the rapidfort-scan.")
    # Print summary of pipelines with rapidfort-scan job not found
    print("\nSummary of Pipelines where rapidfort-scan job was not found:")
    if NOT_FOUND_PIPELINES:
        for not_found_pipeline in NOT_FOUND_PIPELINES:
            print(not_found_pipeline)
    # Exit with status code 1 if there are failed pipelines or pipelines with 'not found' rapidfort-scan jobs
    if FAILED_PIPELINES or NOT_FOUND_PIPELINES:
        sys.exit(1)
    else:
        sys.exit(0)
if __name__ == "__main__":
    main()
