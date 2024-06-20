#!/bin/bash

# Configuration
GITLAB_BASE_URL="https://repo1.dso.mil/api/v4"
PIPELINES_LIST_FILE="ib_pipelines_list.lst"

# Initialize an array to store failed pipeline summaries
FAILED_PIPELINES=()
# Flag to track if any pipeline has failed
HAS_FAILED_PIPELINE=false

get_latest_pipeline() {
    local endpoint="$1"
    local api_url="${GITLAB_BASE_URL}/${endpoint}"

    # Fetch the most recent pipeline details
    local response
    response=$(curl -s "${api_url}?per_page=1")
    local curl_exit_code=$?

    if [[ $curl_exit_code -ne 0 ]]; then
        echo "Error fetching data from ${api_url}"
        return
    fi

    # Extract details using jq
    local pipeline
    pipeline="$(echo "${response}" | jq '.[0]')"
    if [[ "${pipeline}" == "null" ]]; then
        echo "No pipelines found for project: ${endpoint}"
        return
    fi

    # Extract required details
    local pipeline_id status ref web_url
    pipeline_id="$(echo "${pipeline}" | jq -r '.id')"
    status="$(echo "${pipeline}" | jq -r '.status')"
    ref="$(echo "${pipeline}" | jq -r '.ref')"
    web_url="$(echo "${pipeline}" | jq -r '.web_url')"

    echo "Project Endpoint: ${endpoint}"
    echo "Pipeline ID: ${pipeline_id}"
    echo "Status: ${status}"
    echo "Ref: ${ref}"
    echo "Web URL: ${web_url}"
    echo "----------------------------------------"

    # Check if the pipeline status is "failed" and add to summary if true
    if [[ "${status}" == "failed" ]]; then
        FAILED_PIPELINES+=("Project: ${endpoint}, Pipeline ID: ${pipeline_id}, URL: ${web_url}")
        HAS_FAILED_PIPELINE=true
    fi
}

print_failed_summary() {
    if [[ ${#FAILED_PIPELINES[@]} -eq 0 ]]; then
        echo "No failed pipelines found."
    else
        echo "Summary of Failed Pipelines:"
        for failed_pipeline in "${FAILED_PIPELINES[@]}"; do
            echo "${failed_pipeline}"
        done
    fi
}

main() {
    if [[ ! -f "${PIPELINES_LIST_FILE}" ]]; then
        echo "File ${PIPELINES_LIST_FILE} not found!"
        exit 1
    fi

    while IFS= read -r endpoint; do
        # Skip empty lines
        if [[ -z "${endpoint}" ]]; then
            continue
        fi
        get_latest_pipeline "${endpoint}"
    done < "${PIPELINES_LIST_FILE}"

    print_failed_summary

    # Exit with 1 if any pipeline has failed, else exit with 0
    if [[ "$HAS_FAILED_PIPELINE" = true ]]; then
        exit 1
    else
        exit 0
    fi
}

main
