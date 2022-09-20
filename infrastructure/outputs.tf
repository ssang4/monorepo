output "iam-user-vault-unseal-access-key" {
  value = module.iam-user-vault-unseal.iam_access_key_id

  sensitive = true
}

output "iam-user-vault-unseal-secret-key" {
  value = module.iam-user-vault-unseal.iam_access_key_secret

  sensitive = true
}

output "kms-vault-unseal-kms-id" {
  value = module.kms-vault-unseal.key_id
}

output "iam-user-external-dns-access-key" {
  value = module.iam-user-external-dns.iam_access_key_id

  sensitive = true
}

output "iam-user-external-dns-secret-key" {
  value = module.iam-user-external-dns.iam_access_key_secret

  sensitive = true
}

output "iam-user-keycloak-smtp-smtp-username" {
  value = module.iam-user-keycloak-smtp.iam_access_key_id

  sensitive = true
}

output "iam-user-keycloak-smtp-smtp-password" {
  value = module.iam-user-keycloak-smtp.iam_access_key_ses_smtp_password_v4

  sensitive = true
}