#!/bin/bash

set -x
set -e

# add common commands here which should be present in all hardened images
# ref: https://www.mongodb.com/docs/database-tools/

function run_command_version()
{
    local cmd="$1"
    if command -v "$cmd" --version &> /dev/null
    then
        "$cmd" --version
    fi
}

declare -a command_array=(
    bsondump
    mongod
    mongoexport
    mongoimport
    mongos
    mongo
    mongostat
    mongodump
    mongofiles
    mongorestore
    mongosh
    mongotop
)

for cmd in "${command_array[@]}"
do
    run_command_version "$cmd"
done
