module "zones" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "2.9.0"

  zones = {
    "ssang.io" = {}
  }
}

module "zones-free-tier" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "2.9.0"

  zones = {
    "ft.ssang.io" = {}
  }

  providers = {
    aws = aws.free-tier
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
        var.ssang_io_ses_verification_token
      ]
    },
    {
      name = ""
      type = "MX"
      ttl  = "300"
      records = [
        "10 inbound-smtp.eu-west-1.amazonaws.com"
      ]
    },
    {
      name = "ft"
      type = "NS"
      ttl = "300"
      records = module.zones-free-tier.route53_zone_name_servers["ft.ssang.io"]
    }
  ]
}

module "records-free-tier" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "2.9.0"

  zone_name = keys(module.zones-free-tier.route53_zone_zone_id)[0]

  records = [
    {
      name = "opensearch"
      type = "CNAME"
      ttl  = "300"
      records = [
        "search-ssang-wehyrdwus22vihdxgflp23iary.eu-central-1.es.amazonaws.com"
      ]
    }
  ]

  providers = {
    aws = aws.free-tier
   }
}

module "acm-free-tier" {
  source = "terraform-aws-modules/acm/aws"
  version = "4.0.1"

  domain_name = "ft.ssang.io"
  zone_id = module.zones-free-tier.route53_zone_zone_id["ft.ssang.io"]

  subject_alternative_names = [
    "*.ft.ssang.io"
  ]

  wait_for_validation = true

  providers = {
    aws = aws.free-tier
   }
}