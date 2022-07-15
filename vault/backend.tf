# reuse s3 backend from infrastructure dir
terraform {
  backend "s3" {
    bucket         = "ssang-terraform-state"
    dynamodb_table = "terraform-lock"
    encrypt        = true
    key            = "vault/terraform.tfstate"
    region         = "eu-central-1"
  }
}
