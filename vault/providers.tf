terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "3.8.2"
    }
  }
}

provider "vault" {
  address = "https://vault.ssang.io"
  token = var.vault_root_token
}