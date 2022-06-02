#!/bin/bash

function report_pulls()
{
    local REPO_NAME=$1
    local PULL_COUNT=${2-1} # default to single pull count
    #echo "docker pull counter: $REPO_NAME $PULL_COUNT"
    if [ -z "${PULL_COUNTER[$REPO_NAME]}" ]; then
        PULL_COUNTER["$REPO_NAME"]=0
    fi
    echo "docker pull count previous value[$REPO_NAME]:" ${PULL_COUNTER[$REPO_NAME]}
    PULL_COUNTER["$REPO_NAME"]=$((PULL_COUNTER[$REPO_NAME]+"$PULL_COUNT"))
    echo "docker pull count updated to[$REPO_NAME]:" ${PULL_COUNTER[$REPO_NAME]}
}

report_pulls "vinod" 1
report_pulls "vinod" 1
report_pulls "vinod" 5
report_pulls "vinod" 6
report_pulls "gupta" 1
report_pulls "gupta" 3