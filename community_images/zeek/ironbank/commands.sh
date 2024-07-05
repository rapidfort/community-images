#!/bin/bash

set -x
set -e
# help
zkg -h
# Show the value of environment variables
zkg env
# Show Zeek Package Manager configuration info.
zkg config
# Retrieve updated package metadata.
zkg refresh
# Uninstall all packages.
zkg purge
# Generate a Zeek Package Manager configuration file.
zkg autoconfig
# Search packages for matching names.
zkg search http
# Lists packages.
zkg list
# Installs Zeek packages.
zkg install geoip-conn || echo 0
# Upgrade installed packages to latest versions.
zkg upgrade
# Creates a bundle file containing a collection of Zeek packages.
zkg bundle -h