remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket = "ssang-terraform-state"
    key    = "${path_relative_to_include()}/terraform.tfstate"

    region         = "eu-central-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.22.0"
    }
  }
}

provider "aws" {
    profile = "default"
    region = "eu-central-1"
}

provider "aws" {
    profile = "default"
    region = "eu-west-1"

    alias = "ireland"
}

provider "aws" {
  profile = "free-tier"
  region = "eu-central-1"

  alias = "free-tier"
}
EOF
}