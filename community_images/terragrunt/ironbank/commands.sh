#!/bin/bash

set -x
set -e
# Initialize the Terraform working directory
terragrunt init
# Terraform version information
terraform -v
# Validate the configuration files
terragrunt validate
# pply changes to the infrastructure
terragrunt apply -auto-approve
# Generate and show an execution plan
terragrunt plan
# Show the execution plan
terragrunt show
# dependency graph
terragrunt graph -help
# showing
terragrunt state list
# Display the outputs of modules
terragrunt output
# Run tests against the configuration
terragrunt test 
# Format
terragrunt fmt
# Destroy the infrastructure
terragrunt destroy -auto-approve
# Launch the user interface for searching and managing your module catalog.
terragrunt catalog -help