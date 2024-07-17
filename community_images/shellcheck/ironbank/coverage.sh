#!/bin/bash

set -ex

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/scripts/bash_helper.sh

# This tests shellcheck with a script that has no issues and is expected to pass
function test_shellcheck_success() {
    local CONTAINER_NAME=$1
    set +e
    docker exec -i "$CONTAINER_NAME" shellcheck /mnt/test_script_success.sh 
    exit_code=$?
    if [ $exit_code -eq 0 ]; then
       echo "PASS: Shellcheck did not find issues with the script"
    else
       echo "FAIL: Shellcheck found issues with the script"
       exit 1
    fi
}

# This tests shellcheck with a script that has issues and is expected to fail
function test_shellcheck_failure() {
    local CONTAINER_NAME=$1
    set +e
    docker exec -i "$CONTAINER_NAME" shellcheck /mnt/test_script_failure.sh 
    exit_code=$?
    if [ $exit_code -ne 0 ]; then
       echo "PASS: Shellcheck found issues with the script"
    else
       echo "FAIL: Shellcheck did not find issues with the script"
       exit 1
    fi
}

# More shellcheck tests
function test_shellcheck2() {
    local CONTAINER_NAME=$1
    set +e
    docker exec -i "$CONTAINER_NAME" shellcheck /mnt/test_script2.sh 
    exit_code=$?
    if [ $exit_code -ne 0 ]; then
       echo "PASS: Shellcheck found issues with the script"
    else
       echo "FAIL: Shellcheck did not find issues with the script"
       exit 1
    fi
}

function test_shellcheck3() {
    local CONTAINER_NAME=$1
    set +e
    docker exec -i "$CONTAINER_NAME" shellcheck /mnt/test_script3.sh 
    exit_code=$?
    if [ $exit_code -ne 0 ]; then
       echo "PASS: Shellcheck found issues with the script"
    else
       echo "FAIL: Shellcheck did not find issues with the script"
       exit 1
    fi
}

function test_shellcheck4() {
    local CONTAINER_NAME=$1
    set +e
    docker exec -i "$CONTAINER_NAME" shellcheck /mnt/test_script4.sh 
    exit_code=$?
    if [ $exit_code -ne 0 ]; then
       echo "PASS: Shellcheck found issues with the script"
    else
       echo "FAIL: Shellcheck did not find issues with the script"
       exit 1
    fi
}

function test_shellcheck5() {
    local CONTAINER_NAME=$1
    set +e
    docker exec -i "$CONTAINER_NAME" shellcheck /mnt/test_script5.sh 
    exit_code=$?
    if [ $exit_code -ne 0 ]; then
       echo "PASS: Shellcheck found issues with the script"
    else
       echo "FAIL: Shellcheck did not find issues with the script"
       exit 1
    fi
}

function test_shellcheck6() {
    local CONTAINER_NAME=$1
    set +e
    docker exec -i "$CONTAINER_NAME" shellcheck /mnt/test_script6.sh
    exit_code=$?
    if [ $exit_code -ne 0 ]; then
       echo "PASS: Shellcheck found issues with the script"
    else
       echo "FAIL: Shellcheck did not find issues with the script"
       exit 1
    fi
}
