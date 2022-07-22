output "ssang_io_name_servers" {
  description = "Note: Put this in namecheap"

  value = module.zones.route53_zone_name_servers["ssang.io"]
}

output "ft_ssang_io_acm_certificate_arn" {
  value = module.acm-free-tier.acm_certificate_arn  
}