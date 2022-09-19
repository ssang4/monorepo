terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.31.0"
    }
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.22.3"
    }
  }
}

provider "aws" {
  region = "eu-central-1"

  profile = "default"
}

provider "digitalocean" {
  token = var.digitalocean_token
}