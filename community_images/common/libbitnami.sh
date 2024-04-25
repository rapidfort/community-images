#!/bin/bash
#
# RapidFort Bitnami custom library

# shellcheck disable=SC1091

# Load Generic Libraries
. /opt/bitnami/scripts/liblog.sh
# set -x
# Constants
BOLD='\033[1m'

# PASSWORD='rf123@123'
# RF_ACCESS_TOKEN='rf123@124'
# Functions

########################
# Print the welcome page
# Globals:
#   DISABLE_WELCOME_MESSAGE
#   BITNAMI_APP_NAME
# Arguments:
#   None
# Returns:
#   None
#########################

print_welcome_page() {
    if [[ -z "${DISABLE_WELCOME_MESSAGE:-}" ]]; then
        if [[ -n "$BITNAMI_APP_NAME" ]]; then
            print_image_welcome_page
            
        fi
    fi
}

########################
# Print the welcome page for a RF Bitnami Docker image
# Globals:
#   BITNAMI_APP_NAME
# Arguments:
#   None
# Returns:
#   None
#########################
print_image_welcome_page() {
    local github_url="https://github.com/rapidfort/community-images"

    log ""
    log "${BOLD}Welcome to the RapidFort optimized, hardened image for Bitnami ${BITNAMI_APP_NAME} container${RESET}"
    log "Subscribe to project updates by watching ${BOLD}${github_url}${RESET}"
    log "Submit issues and feature requests at ${BOLD}${github_url}/issues/new/choose${RESET}"
    log ""
}
