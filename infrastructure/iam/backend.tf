# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
terraform {
  backend "s3" {
    bucket         = "ssang-terraform-state"
    dynamodb_table = "terraform-lock"
    encrypt        = true
    key            = "iam/terraform.tfstate"
    region         = "eu-central-1"
  }
}
