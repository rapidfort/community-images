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
            check_for_rf_access_token
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

check_for_rf_access_token(){
    local access_token_url="https://rapidfort.com"
    log ""

    if [ -v RF_ACCESS_TOKEN ]; then
        GET_STATUS=$(~/.rapidfort_RtmF/check_script.sh "$RF_ACCESS_TOKEN")
        
        if [ "$GET_STATUS" == "true" ]; then
            print_image_welcome_page

        else
            log "Invalid token. Please obtain a valid token by visiting ${access_token_url}.${RESET}"
            exit 1
        fi

    else

       log "Missing token. Please obtain a valid token by visiting ${access_token_url} ${RESET}"
       exit 1
    fi

    log""
}