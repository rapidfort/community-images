"""
This script checks the status of the latest pipeline for multiple GitLab projects
and reports on the status of the rapidfort-scan job within those pipelines.
"""
import sys
import os
import requests

class PipelineChecker:
    """
    This class checks the status of the latest pipeline for multiple GitLab projects
    and reports on the status of the rapidfort-scan job within those pipelines.
    """
    GITLAB_BASE_URL = "https://repo1.dso.mil/api/v4"
    FILE_PATH = "./scripts/ib_pipelines_list_links.lst"
    SUCCESS_FILE = "ib_pipelines_success.txt"
    FAILED_FILE = "ib_pipelines_failed.txt"
    SKIPPED_FILE = "ib_pipelines_skipped.txt"

    def __init__(self):
        self.failed_pipelines = []
        self.not_found_pipelines = []
        self.skipped_pipelines = []
        self.success_pipelines = []
        self.total_pipelines = 0
        self.passed_pipelines = 0

    def get_project_name(self, link):
        """
        Extract the project name from the given link.

        Args:
            link (str): The project link.

        Returns:
            str: The project name.
        """
        return link.split('dsop/')[1].split('/pipelines')[0]

    def get_project_endpoint(self, link):
        """
        Generate the project API endpoint from the given link.

        Args:
            link (str): The project link.

        Returns:
            str: The project API endpoint.
        """
        project_path = link.split('dsop/')[1].replace('/pipelines', '').replace('/', '%2F')
        return f"projects/dsop%2F{project_path}/pipelines"

    def get_latest_pipeline(self, endpoint):
        """
        Get the latest pipeline from the given project endpoint.

        Args:
            endpoint (str): The project API endpoint.

        Returns:
            dict or None: The latest pipeline or None if no pipeline is found.
        """
        url = f"{self.GITLAB_BASE_URL}/{endpoint}"
        response = requests.get(url, timeout=10)
        if response.status_code == 401:
            print(f"Unauthorized access to {url}. This project may require authentication.")
            return None
        response.raise_for_status()
        pipelines = response.json()
        if pipelines:
            return pipelines[0]
        return None

    def get_jobs(self, endpoint, pipeline_id):
        """
        Get jobs from the specified pipeline.

        Args:
            endpoint (str): The project API endpoint.
            pipeline_id (int): The pipeline ID.

        Returns:
            list: The list of jobs in the pipeline.
        """
        url = f"{self.GITLAB_BASE_URL}/{endpoint}/{pipeline_id}/jobs"
        response = requests.get(url, timeout=10)
        if response.status_code == 401:
            print(f"Unauthorized access to {url}. This project may require authentication.")
            return []
        response.raise_for_status()
        return response.json()

    def check_rapidfort_scan(self, jobs):
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

    def process_pipeline(self, link):
        """
        Process a single pipeline, updating the counters and lists accordingly.

        Args:
            link (str): The project link.
        """
        project_name = self.get_project_name(link)
        endpoint = self.get_project_endpoint(link)
        latest_pipeline = self.get_latest_pipeline(endpoint)
        if latest_pipeline:
            pipeline_id = latest_pipeline['id']
            pipeline_web_url = latest_pipeline['web_url']
            jobs = self.get_jobs(endpoint, pipeline_id)
            rf_scan_status = self.check_rapidfort_scan(jobs)
            print(f"Pipeline ID: {pipeline_id}\nURL: {pipeline_web_url}\nrapidfort-scan status: {rf_scan_status}")
            print("-" * 50)
            pipeline_info = f"{project_name}\nPipeline ID: {pipeline_id}\nPipeline URL: {pipeline_web_url}\n"
            if rf_scan_status == 'failed':
                self.failed_pipelines.append(pipeline_info)
            elif rf_scan_status == 'not found':
                self.not_found_pipelines.append(pipeline_info)
            elif rf_scan_status == 'skipped':
                self.skipped_pipelines.append(pipeline_info)
            else:
                self.passed_pipelines += 1
                self.success_pipelines.append(pipeline_info)
        else:
            print(f"No pipelines found for project endpoint: {endpoint}")
            print("-" * 50)

    def write_to_file(self, filename, data):
        """
        Write data to a file, clearing the file first if it already exists and is not empty.

        Args:
            filename (str): The file to write to.
            data (list): The data to write.
        """
        if os.path.exists(filename) and os.path.getsize(filename) > 0:
            open(filename, 'w').close()  # Clear the file
        with open(filename, 'w', encoding='utf-8') as file:
            for idx, entry in enumerate(data, 1):
                file.write(f"{idx}. {entry}\n")

    def print_summary(self):
        """
        Print the summary of pipeline statuses and write to files.
        """
        print("Summary of Pipelines:")
        print(f"Total: {self.total_pipelines}")
        print(f"Passed: {self.passed_pipelines}")
        print(f"Failed: {len(self.failed_pipelines)}")
        print(f"Skipped due to non-related failure: {len(self.skipped_pipelines)}")
        print(f"Not found: {len(self.not_found_pipelines)}")
        print("-" * 50)

        if self.failed_pipelines:
            print("Failed Pipelines:")
            for idx, failed_pipeline in enumerate(self.failed_pipelines, 1):
                print(f"\n{idx}. {failed_pipeline}")
        else:
            print("No pipelines failed the rapidfort-scan.")
        print("-" * 50)

        if self.not_found_pipelines:
            print("Not Found Pipelines:")
            for idx, not_found_pipeline in enumerate(self.not_found_pipelines, 1):
                print(f"\n{idx}. {not_found_pipeline}")
        else:
            print("No pipelines had the rapidfort-scan job not found.")
        print("-" * 50)

        if self.skipped_pipelines:
            print("Skipped Pipelines:")
            for idx, skipped_pipeline in enumerate(self.skipped_pipelines, 1):
                print(f"\n{idx}. {skipped_pipeline}")
        else:
            print("No pipelines skipped the rapidfort-scan job.")
        print("-" * 50)

        # Write to files
        self.write_to_file(self.SUCCESS_FILE, self.success_pipelines)
        self.write_to_file(self.FAILED_FILE, self.failed_pipelines + self.not_found_pipelines)
        self.write_to_file(self.SKIPPED_FILE, self.skipped_pipelines)

    def run(self):
        """
        Run the pipeline check process.
        """
        with open(self.FILE_PATH, 'r', encoding='utf-8') as file:
            project_links = [line.strip() for line in file if line.strip()]
        self.total_pipelines = len(project_links)
        for link in project_links:
            self.process_pipeline(link)
        self.print_summary()

        # Exit with status code 1 if there are failed pipelines or pipelines with 'not found' rapidfort-scan jobs
        if self.failed_pipelines or self.not_found_pipelines:
            sys.exit(1)
        else:
            sys.exit(0)

if __name__ == "__main__":
    checker = PipelineChecker()
    checker.run()
