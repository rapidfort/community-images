#!/bin/bash

set -x
set -e

trivy -v

#Image Scanning
trivy image -f table  python:3.4-alpine

#FileSystem Scan
trivy -f json  -o output.json fs ../../tmp/filesystem
cat output.json

#rootfs
trivy rootfs ../../root

#Repo Scanning
trivy repo  -f table -o output.csv https://github.com/aquasecurity/trivy-ci-test
cat output.csv

#VM Scanning
trivy vm --scanners vuln disk.vmdk || echo 0

#k8s cluster scannig
trivy k8s --kubeconfig /tmp/.kube/config --report  summary all || echo 0

#AWS Scan
trivy aws --region us-east-1 || echo 0

#SBOM Generation || spdx tag format
trivy image --format spdx --output result_spdx_tag.spdx alpine:latest

#SBOM Generation || spdx json format
trivy image --format spdx-json --output result_spdx_json.spdx.json python:latest

#SBOM Generation || cyclonedx format
trivy image --scanners vuln --format cyclonedx --output result_cyclonedx.json python:latest

#SBOM Scanning

trivy sbom result_spdx_tag.spdx
trivy sbom result_spdx_json.spdx.json
trivy sbom -f json result_cyclonedx.json