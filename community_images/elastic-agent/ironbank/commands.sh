#!/bin/bash

set -x
set -e

elastic-agent enroll http://kibana:5601/api/fleet/agents/enroll --enrollment-token=tkwYZd4JSuKaV-iaToACuQ || echo 0

elastic-agent status || echo 0

elastic-agent version

elastic-agent watch

elastic-agent uninstall --help

elastic-agent completion bash

elastic-agent component

elastic-agent enroll --help

elastic-agent inspect

elastic-agent install --help

elastic-agent logs

elastic-agent run --help

elastic-agent upgrade --help

elastic-agent diagnostics