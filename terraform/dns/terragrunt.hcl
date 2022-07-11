include "root" {
  path = find_in_parent_folders()
}

dependency "email" {
  config_path = "../email"
}

inputs = {
  ssang_io_ses_verification_token = dependency.email.outputs.ssang_io_ses_verification_token
}