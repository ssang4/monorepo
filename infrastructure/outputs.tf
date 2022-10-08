output "iam-user-vault-access-key" {
  value = module.iam-user-vault.iam_access_key_id

  sensitive = true
}

output "iam-user-vault-secret-key" {
  value = module.iam-user-vault.iam_access_key_secret

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

output "iam-user-alertmanager-smtp-smtp-username" {
  value = module.iam-user-alertmanager-smtp.iam_access_key_id

  sensitive = true
}

output "iam-user-alertmanager-smtp-smtp-password" {
  value = module.iam-user-alertmanager-smtp.iam_access_key_ses_smtp_password_v4

  sensitive = true
}

output "iam-saml-provider-keycloak-arn" {
  value = aws_iam_saml_provider.keycloak.arn
}

output "iam-role-saml-keycloak-admin-arn" {
  value = module.iam-role-saml-keycloak-admin.iam_role_arn
}

output "iam-user-fluent-bit-access-key" {
  value = module.iam-user-fluent-bit.iam_access_key_id

  sensitive = true
}

output "iam-user-fluent-bit-secret-key" {
  value = module.iam-user-fluent-bit.iam_access_key_secret

  sensitive = true
}