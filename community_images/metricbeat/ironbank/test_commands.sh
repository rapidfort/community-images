#!/bin/bash

set -x
set -e

metricbeat version
metricbeat export modules
metricbeat keystore --help
metricbeat test config
metricbeat setup --pipelines
metricbeat run --help