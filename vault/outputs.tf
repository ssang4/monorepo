output "ssl-private-key-elasticsearch" {
  value = vault_pki_secret_backend_cert.elasticsearch.private_key

  sensitive = true
}

output "ssl-certificate-elasticsearch" {
  value = vault_pki_secret_backend_cert.elasticsearch.certificate
}

output "ssl-private-key-kibana" {
  value = vault_pki_secret_backend_cert.kibana.private_key

  sensitive = true
}

output "ssl-certificate-kibana" {
  value = vault_pki_secret_backend_cert.kibana.certificate
}

output "ssl-ca" {
  value = vault_pki_secret_backend_root_sign_intermediate.this.ca_chain
}