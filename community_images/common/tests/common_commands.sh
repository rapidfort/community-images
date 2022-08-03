#!/bin/bash

set -x
set -e

# Add common commands here which should be present in all hardened images

function run_command_version()
{
    local cmd="$1"
    if command -v "$cmd" --version &> /dev/null
    then
        "$cmd" --version
    fi
}

sleep 1

declare -a command_array=(
    cp mkdir chmod ls mv rm ln rmdir chgrp chown touch cat grep sed tar sort head
)

for cmd in "${command_array[@]}"
do
    run_command_version "$cmd"
done

# add clear command
if command -v clear -V &> /dev/null
then
    clear -V
fi
