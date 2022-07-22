include "root" {
  path = find_in_parent_folders()
}

dependency "dns" {
  config_path = "../dns"
}

inputs = {
  ft_ssang_io_acm_certificate_arn = dependency.dns.outputs.ft_ssang_io_acm_certificate_arn
}