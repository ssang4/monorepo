data "aws_caller_identity" "this" {}

locals {
  ssang_io_email_bucket_name = "ssang-io-ses-emails"
  ses_receipt_rule_set_name  = "default"
  ses_receipt_rule_name      = "store-on-s3"
}

resource "aws_ses_domain_identity" "this" {
  domain = "ssang.io"

  provider = aws.ireland
}

resource "aws_ses_domain_identity_verification" "this" {
  domain = aws_ses_domain_identity.this.id
  
  provider   = aws.ireland
}

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.3.0"

  bucket = local.ssang_io_email_bucket_name
  acl    = "private"

  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true

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