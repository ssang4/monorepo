terraform {
  backend "s3" {
    bucket         = "ssang-terraform-state"
    key            = "database"
    region         = "eu-central-1"
    dynamodb_table = "ssang-terraform-lock"
    profile        = "default"
  }

  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.17.1"
    }
  }
}

provider "postgresql" {
  host     = "localhost"
  port     = 5432
  username = "postgres"
  password = var.postgres_password
  sslmode  = "disable"
}