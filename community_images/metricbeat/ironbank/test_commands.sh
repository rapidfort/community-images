#!/bin/bash

set -x
set -e

metricbeat version
metricbeat setup --pipelines
metricbeat export ilm-policy
metricbeat keystore --help
metricbeat test config
metricbeat run --help