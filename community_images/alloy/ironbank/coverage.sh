#!/bin/bash

set -x
set -e


alloy completion --help

alloy convert --help

alloy fmt --help

alloy run --help

alloy tools --help

alloy tools prometheus.remote_write --help

alloy completion bash

alloy completion fish

alloy completion powershell

alloy completion zsh

alloy convert -f prometheus -o alloy-config.yaml /tmp/prometheus.yaml || echo 0

alloy fmt /tmp/prometheus.yaml || echo 0

alloy run /etc/alloy/config.alloy || echo 0
