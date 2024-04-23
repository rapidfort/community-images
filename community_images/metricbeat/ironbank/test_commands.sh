#!/bin/bash

set -x
set -e

metricbeat version
metricbeat export --help
metricbeat keystore --help
metricbeat test --help
metricbeat setup --help
metricbeat run --help