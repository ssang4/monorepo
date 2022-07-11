module "terraform_state_s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.3.0"

  bucket = "ssang-terraform-state"
  acl    = "private"

  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

module "terraform_lock_dynamodb_table" {
  source = "terraform-aws-modules/dynamodb-table/aws"
  version = "2.0.0"

  name = "terraform-lock"
  hash_key = "LockID"

  attributes = [
    {
      name = "LockID"
      type = "S"
    }
  ]
}