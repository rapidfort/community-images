#!/bin/bash

set -x
set -e

metricbeat version
metricbeat export --help
metricbeat keystore --help
metricbeat test --help
metricbeat setup --help
metricbeat modules enable kibana-xpack
metricbeat modules enable elasticsearch-xpack
metricbeat modules enable elasticsearch
metricbeat modules enable kibana
metricbeat modules enable beat-xpack
metricbeat modules enable beat
metricbeat modules enable http
metricbeat run --help