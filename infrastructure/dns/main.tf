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
    }
  ]
}