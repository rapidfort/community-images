import sys
import requests

# Configuration
GITLAB_BASE_URL = "https://repo1.dso.mil/api/v4"
FILE_PATH = "./scripts/ib_pipelines_list_links.lst"

FAILED_PIPELINES = []

def get_project_endpoint(link):
    project_path = link.split('dsop/')[1].replace('/pipelines', '').replace('/', '%2F')
    return f"projects/dsop%2F{project_path}/pipelines"

def get_latest_pipeline(endpoint):
    url = f"{GITLAB_BASE_URL}/{endpoint}"
    response = requests.get(url)
    if response.status_code == 401:
        print(f"Unauthorized access to {url}. This project may require authentication.")
        return None
    response.raise_for_status()
    pipelines = response.json()
    if pipelines:
        return pipelines[0]
    return None

def get_jobs(endpoint, pipeline_id):
    url = f"{GITLAB_BASE_URL}/{endpoint}/{pipeline_id}/jobs"
    response = requests.get(url)
    if response.status_code == 401:
        print(f"Unauthorized access to {url}. This project may require authentication.")
        return []
    response.raise_for_status()
    return response.json()

def check_rapidfort_scan(jobs):
    for job in jobs:
        if job['name'] == 'rapidfort-scan':
            return job['status']
    return "not found"

def main():
    with open(FILE_PATH, 'r') as file:
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
        else:
            print(f"No pipelines found for project endpoint: {endpoint}")
            print("-" * 50)

    # Print summary of failed pipelines
    print("\nSummary of Pipelines that Failed the rapidfort-scan:")
    if FAILED_PIPELINES:
        for failed_pipeline in FAILED_PIPELINES:
            print(failed_pipeline)
        sys.exit(1)  # Exit with status code 1 if there are failed pipelines
    else:
        print("\nNo pipelines failed the rapidfort-scan.")
        sys.exit(0)  # Exit with status code 0 if no pipelines failed

if __name__ == "__main__":
    main()
