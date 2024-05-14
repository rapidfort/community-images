# terragrunt.hcl

terraform {
  source = "/home/terraform"
}

inputs = {
  region      = "us-west-2"
  environment = "dev"
}
