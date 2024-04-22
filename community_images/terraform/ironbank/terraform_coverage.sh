#!/bin/bash

set -x
set -e


terraform --version
terraform init
terraform fmt
terraform validate
terraform plan 
terraform apply -auto-approve
curl -I http://localhost:8000
terraform show -json
terraform refresh
terraform output -json
terraform state list 
terraform state show || echo 0
terraform graph
echo 'split(",", "foo,bar,baz")' | terraform console
terraform destroy -auto-approve