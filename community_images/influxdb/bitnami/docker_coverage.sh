#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker coverage = $JSON"
