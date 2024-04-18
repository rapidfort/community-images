#!/bin/bash

set -x
set -e

metricbeat version
metricbeat export config
metricbeat keystore --help
metricbeat test
metricbeat modules enable kibana-xpack
metricbeat modules enable elasticsearch-xpack
metricbeat modules enable elasticsearch
metricbeat modules enable kibana
metricbeat modules enable beat-xpack
metricbeat modules enable beat
metricbeat modules enable http
metricbeat run --help