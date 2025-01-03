"""
This script checks the status of the latest pipeline for multiple GitLab projects
and reports on the status of the rapidfort-scan job within those pipelines.
It also logs the information to a CSV file for further analysis.
"""

import csv
from datetime import datetime, timedelta, timezone
import sys
import os
import re
import requests

class PipelineChecker:
    """
    This class checks the status of the latest pipeline for multiple GitLab projects
    and reports on the status of the rapidfort-scan job within those pipelines.
    """
    GITLAB_BASE_URL = "https://repo1.dso.mil/api/v4"
    FILE_PATH = "./scripts/ib_pipelines_list_links.lst"
    CSV_FILE_PATH = "pipeline_logs.csv"

    def __init__(self):
        self.failed_pipelines = []
        self.not_found_pipelines = []
        self.skipped_pipelines = []
        self.inactive_pipelines = []
        self.partial_coverage_pipelines = []
        self.total_pipelines = 0
        self.passed_pipelines = 0
        self.init_csv_file()

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
        response = requests.get(url, timeout=30)
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
        response = requests.get(url, timeout=30)
        if response.status_code == 401:
            print(f"Unauthorized access to {url}. This project may require authentication.")
            return []
        response.raise_for_status()
        return response.json()

    def get_job_trace(self, job_web_url):
        """
        Get the log trace of a specific job using the job's web URL.

        Args:
            job_web_url (str): The web URL of the job.

        Returns:
            str: The job log trace.
        """
        raw_log_url = job_web_url + '/trace'
        response = requests.get(raw_log_url, timeout=60)
        if response.status_code != 200:
            print(
                f"Failed to retrieve job trace from {raw_log_url}. "
                f"Status code: {response.status_code}"
            )
            return ""
        return response.text

    def check_rapidfort_scan(self, jobs):
        """
        Check the status of the rapidfort-scan job.

        Args:
            jobs (list): The list of jobs in the pipeline.

        Returns:
            tuple: (status, job) of the rapidfort-scan job.
        """
        for job in jobs:
            if job['name'] == 'rapidfort-scan':
                return job['status'], job
        return "not found", None

    @staticmethod
    def format_timestamp(iso_timestamp):
        """
        Convert an ISO 8601 timestamp to a more readable format.

        Args:
            iso_timestamp (str): The ISO 8601 timestamp.

        Returns:
            str: The formatted timestamp.
        """
        dt = datetime.fromisoformat(iso_timestamp.replace("Z", "+00:00"))
        return dt.strftime("%B %d, %Y, %I:%M:%S %p %Z")

    @staticmethod
    def is_pipeline_inactive(pipeline_created_at):
        """
        Check if the pipeline was last run more than 3 days ago.

        Args:
            pipeline_created_at (str): The ISO 8601 timestamp of the pipeline creation.

        Returns:
            bool: True if the pipeline was run more than 3 days ago, False otherwise.
        """
        dt = datetime.fromisoformat(pipeline_created_at.replace("Z", "+00:00"))
        return datetime.now(timezone.utc) - dt > timedelta(days=3)

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
            pipeline_time_created = self.format_timestamp(latest_pipeline['created_at'])
            if self.is_pipeline_inactive(latest_pipeline['created_at']):
                self.inactive_pipelines.append(
                    f"{project_name}\nPipeline ID: {pipeline_id}\n"
                    f"Pipeline URL: {pipeline_web_url}"
                )
            jobs = self.get_jobs(endpoint, pipeline_id)
            rf_scan_status, rf_scan_job = self.check_rapidfort_scan(jobs)
            print(
                f"Time Created At: {pipeline_time_created}\n"
                f"Pipeline ID: {pipeline_id}\nURL: {pipeline_web_url}\n"
                f"rapidfort-scan status: {rf_scan_status}"
            )
            print("-" * 50)
            if rf_scan_status == 'success':
                job_trace = self.get_job_trace(rf_scan_job['web_url'])
                if re.search(r'Partial coverage completed', job_trace, re.IGNORECASE):
                    self.partial_coverage_pipelines.append(
                        f"{project_name}\nPipeline ID: {pipeline_id}\n"
                        f"Pipeline URL: {pipeline_web_url}"
                    )
                    rf_scan_status = 'success (partial coverage)'
                else:
                    self.passed_pipelines += 1
            elif rf_scan_status == 'failed':
                self.failed_pipelines.append(
                    f"{project_name}\nPipeline ID: {pipeline_id}\n"
                    f"Pipeline URL: {pipeline_web_url}"
                )
            elif rf_scan_status == 'not found':
                self.not_found_pipelines.append(
                    f"{project_name}\nPipeline ID: {pipeline_id}\n"
                    f"Pipeline URL: {pipeline_web_url}"
                )
            elif rf_scan_status == 'skipped':
                self.skipped_pipelines.append(
                    f"{project_name}\nPipeline ID: {pipeline_id}\n"
                    f"Pipeline URL: {pipeline_web_url}"
                )
            else:
                print(f"Unknown rapidfort-scan status: {rf_scan_status}")
                print("-" * 50)
            self.write_to_csv(
                pipeline_time_created, pipeline_id, pipeline_web_url,
                rf_scan_status, project_name
            )
        else:
            print(f"No pipelines found for project endpoint: {endpoint}")
            print("-" * 50)

    def init_csv_file(self):
        """
        Initialize and clear the CSV file.
        """
        with open(self.CSV_FILE_PATH, 'w', newline='', encoding='utf-8') as file:
            writer = csv.writer(file)
            writer.writerow([
                "Pipeline Time Created", "Pipeline ID", "Pipeline URL",
                "rapidfort-scan Status", "Project Name"
            ])
    # pylint: disable=R0913, R0917
    def write_to_csv(self, pipeline_time_created, pipeline_id, pipeline_web_url,
                     rf_scan_status, project_name):
        """
        Write pipeline information to the CSV file.

        Args:
            pipeline_time_created (str): The time the pipeline was created.
            pipeline_id (int): The ID of the pipeline.
            pipeline_web_url (str): The web URL of the pipeline.
            rf_scan_status (str): The status of the rapidfort-scan job.
            project_name (str): The name of the project.
        """
        with open(self.CSV_FILE_PATH, 'a', newline='', encoding='utf-8') as file:
            writer = csv.writer(file)
            writer.writerow([
                pipeline_time_created, pipeline_id, pipeline_web_url,
                rf_scan_status, project_name
            ])

    def print_summary(self):
        """
        Print the summary of pipeline statuses.
        """
        print("Summary of Pipelines:")
        print(f"Total: {self.total_pipelines}")
        print(f"Passed: {self.passed_pipelines}")
        print(
            f"Failed (including partial coverage): "
            f"{len(self.failed_pipelines) + len(self.partial_coverage_pipelines)}"
        )
        print(f"Skipped due to non-related failure: {len(self.skipped_pipelines)}")
        print(f"Not found: {len(self.not_found_pipelines)}")
        print(f"Inactive (not run in last 3 days): {len(self.inactive_pipelines)}")
        print("-" * 50)

        combined_failed_pipelines = self.failed_pipelines + self.partial_coverage_pipelines
        if combined_failed_pipelines:
            print("Failed Pipelines (including partial coverage):")
            for idx, pipeline in enumerate(combined_failed_pipelines, 1):
                print(f"\n{idx}. {pipeline}")
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

        if self.inactive_pipelines:
            print("Inactive Pipelines (not run in last 3 days):")
            for idx, inactive_pipeline in enumerate(self.inactive_pipelines, 1):
                print(f"\n{idx}. {inactive_pipeline}")
        else:
            print("All pipelines have been run in the last 3 days.")
        print("-" * 50)

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

        # Check if there are failed pipelines or pipelines with 'not found' rapidfort-scan jobs
        if self.failed_pipelines or self.not_found_pipelines or self.partial_coverage_pipelines:
            with open(os.getenv('GITHUB_ENV'), 'a', encoding='utf-8') as env_file:
                env_file.write("workflow_status=failed\n")
            sys.exit(1)  # Exit with non-zero status
        else:
            with open(os.getenv('GITHUB_ENV'), 'a', encoding='utf-8') as env_file:
                env_file.write("workflow_status=passed\n")
            sys.exit(0)  # Exit with zero status

if __name__ == "__main__":
    checker = PipelineChecker()
    checker.run()
