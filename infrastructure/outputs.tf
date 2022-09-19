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