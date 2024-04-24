#!/bin/bash

set -x
set -e

metricbeat version
metricbeat export modules
metricbeat keystore list
metricbeat test output
metricbeat setup --help
metricbeat run --help