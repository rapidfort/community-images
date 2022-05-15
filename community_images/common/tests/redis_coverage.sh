#!/bin/bash

set -x
set -e

# add common commands here which should be present in all hardened images

redis-benchmark --help
redis-cli --help
