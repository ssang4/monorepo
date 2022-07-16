output "vault_iam_user_credentials" {
  value = {
    access_key = module.vault-iam-user.iam_access_key_id
    secret_key = module.vault-iam-user.iam_access_key_secret
  }

  sensitive = true
}

output "external_dns_iam_user_credentials" {
  value = {
    access_key = module.external-dns-iam-user.iam_access_key_id
    secret_key = module.external-dns-iam-user.iam_access_key_secret
  }

  sensitive = true
}