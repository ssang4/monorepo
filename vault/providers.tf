terraform {
  backend "s3" {
    bucket         = "ssang-terraform-state"
    key            = "infrastructure"
    region         = "eu-central-1"
    dynamodb_table = "ssang-terraform-lock"
    profile        = "default"
  }

  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "3.8.2"
    }
  }
}

provider "vault" {
  address = "https://vault.ssang.io"
  token   = var.vault_root_token
}