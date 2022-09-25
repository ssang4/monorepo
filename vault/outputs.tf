output "ssl-ca-certificate" {
  value = vault_pki_secret_backend_root_cert.this.certificate
}