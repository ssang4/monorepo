data "aws_caller_identity" "this" {}

locals {
  ssang_io_email_bucket_name = "ssang-io-ses-emails"
  ses_receipt_rule_set_name  = "default"
  ses_receipt_rule_name      = "store-on-s3"
}

module "zones" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "2.9.0"

  zones = {
    "ssang.io" = {}
  }
}

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "2.9.0"

  zone_name = keys(module.zones.route53_zone_zone_id)[0]

  records = [
    {
      name = "_amazonses"
      type = "TXT"
      ttl  = "300"
      records = [
        aws_ses_domain_identity.this.verification_token
      ]
    },
    {
      name = ""
      type = "MX"
      ttl  = "300"
      records = [
        "10 inbound-smtp.eu-west-1.amazonaws.com"
      ]
    }
  ]
}

resource "aws_ses_domain_identity" "this" {
  domain = "ssang.io"

  provider = aws.ireland
}

resource "aws_ses_domain_identity_verification" "this" {
  domain = aws_ses_domain_identity.this.id

  depends_on = [module.records]
  provider   = aws.ireland
}

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.3.0"

  bucket = local.ssang_io_email_bucket_name
  acl    = "private"

  attach_policy = true
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Principal = {
          Service = "ses.amazonaws.com"
        }
        Effect   = "Allow"
        Action   = "s3:PutObject"
        Resource = "arn:aws:s3:::${local.ssang_io_email_bucket_name}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceAccount" = data.aws_caller_identity.this.account_id
            "AWS:SourceArn"     = "arn:aws:ses:eu-west-1:${data.aws_caller_identity.this.account_id}:receipt-rule-set/${local.ses_receipt_rule_set_name}:receipt-rule/${local.ses_receipt_rule_name}"
          }
        }
      }
    ]
  })
}

resource "aws_ses_receipt_rule_set" "this" {
  rule_set_name = local.ses_receipt_rule_set_name

  provider = aws.ireland
}

resource "aws_ses_active_receipt_rule_set" "this" {
  rule_set_name = aws_ses_receipt_rule_set.this.id

  provider = aws.ireland
}

resource "aws_ses_receipt_rule" "this" {
  name          = local.ses_receipt_rule_name
  rule_set_name = aws_ses_receipt_rule_set.this.id

  enabled      = true
  scan_enabled = true

  s3_action {
    bucket_name = module.s3_bucket.s3_bucket_id
    position    = 1
  }

  provider = aws.ireland
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"

  cidr = "10.0.0.0/16"

  azs = [ "eu-central-1a", "eu-central-1b", "eu-central-1c" ]
  public_subnets = [ "10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24" ]
}

module "terraform_state_s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.3.0"

  bucket = "ssang-terraform-state"
  acl    = "private"
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