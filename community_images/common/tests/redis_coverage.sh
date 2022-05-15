#!/bin/bash

set -x
set +e # some of these commands return non-0 exit code

# add common commands here which should be present in all hardened images

redis-benchmark --help
redis-cli --help
