#!/bin/bash
set -ex

# This is a simple shell script with issues that shellcheck is expected to detect
echo "Hello, world!"

# Error: Missing double quotes around "$USER"
echo Hello, $USER
