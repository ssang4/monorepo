terraform {
  backend "s3" {
    bucket = "ssang-terraform-state"
    key = "terraform.tfstate"
    region = "eu-central-1"
    dynamodb_table = "terraform-lock"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.22.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

provider "aws" {
  profile = "default"
  region  = "eu-west-1"

  alias = "ireland"
}