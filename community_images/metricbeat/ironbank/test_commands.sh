#!/bin/bash

set -x
set -e

# Check Metricbeat version
metricbeat version
# Export Metricbeat available modules
metricbeat export modules
# testing keystore list subcommand
metricbeat keystore list
#Tests the output configuration.
metricbeat test output
# for initial env help command
metricbeat setup --help
# Runs Metricbeat
metricbeat run --help