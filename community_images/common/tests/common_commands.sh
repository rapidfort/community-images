#!/bin/sh

set -x
set -e
export TERM=xterm
# Add common commands here which should be present in all hardened images

run_commands()
{
    cmd="$1"
    if command -v "$cmd" --help > /dev/null
    then
        "$cmd" --help
    fi
}

sleep 1

set -- cp mkdir chmod ls mv rm ln rmdir chgrp chown touch cat grep sed tar sort head date

for cmd in "$@"
do
    run_commands "$cmd"
done

# add clear command
if command -v clear -V > /dev/null
then
    clear -V
fi
