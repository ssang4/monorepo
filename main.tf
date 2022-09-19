module "route53-zones" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "2.9.0"

  zones = {
    "ssang.io" = {}
  }
}

module "route53-zone-ssang-io-records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "2.9.0"

  zone_name = keys(module.route53-zones.route53_zone_zone_id)[0]

  records = [
    {
      name = ""
      type = "TXT"
      ttl  = 300
      records = [
        "protonmail-verification=b86f23bf8f37d2c3a9293056e1461267b33aee81",
        "v=spf1 include:_spf.protonmail.ch mx ~all",
      ]
    },
    {
      name = ""
      type = "MX"
      ttl  = 300
      records = [
        "10 mail.protonmail.ch",
        "20 mailsec.protonmail.ch",
      ]
    },
    {
      name = "protonmail._domainkey"
      type = "CNAME"
      ttl  = 300
      records = [
        "protonmail.domainkey.dkkgf6iqytwe7gvfpqlrveuupy4oqrfn5oatiircsi7sp4zodrcxq.domains.proton.ch."
      ]
    },
    {
      name = "protonmail2._domainkey"
      type = "CNAME"
      ttl  = 300
      records = [
        "protonmail2.domainkey.dkkgf6iqytwe7gvfpqlrveuupy4oqrfn5oatiircsi7sp4zodrcxq.domains.proton.ch."
      ]
    },
    {
      name = "protonmail3._domainkey"
      type = "CNAME"
      ttl  = 300
      records = [
        "protonmail3.domainkey.dkkgf6iqytwe7gvfpqlrveuupy4oqrfn5oatiircsi7sp4zodrcxq.domains.proton.ch."
      ]
    },
  ]
}