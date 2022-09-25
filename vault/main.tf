resource "vault_mount" "kvv2" {
  path = "secret"
  type = "kv"
  options = {
    version = "2"
  }
}

resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "this" {
  backend = vault_auth_backend.kubernetes.path

  kubernetes_host        = "https://kubernetes.default.svc"
  disable_iss_validation = true
}

resource "vault_kubernetes_auth_backend_role" "cluster-secret-store" {
  backend = vault_auth_backend.kubernetes.path

  role_name = "cluster-secret-store"

  bound_service_account_namespaces = ["external-secrets"]
  bound_service_account_names      = ["cluster-secret-store"]

  token_policies = [
    vault_policy.cluster-secret-store.name
  ]
  token_ttl = 600
}

resource "vault_policy" "cluster-secret-store" {
  name = "cluster-secret-store"

  policy = <<EOT
path "secret/*" {
    capabilities = [ "read" ]
}
EOT
}

data "vault_generic_secret" "vault" {
  path = "secret/vault"
}

resource "vault_jwt_auth_backend" "oidc" {
  path = "oidc"
  type = "oidc"

  oidc_discovery_url = "https://keycloak.ssang.io/realms/master"
  bound_issuer       = "https://keycloak.ssang.io/realms/master"

  oidc_client_id     = data.vault_generic_secret.vault.data.keycloak-oidc-client-id
  oidc_client_secret = data.vault_generic_secret.vault.data.keycloak-oidc-client-secret
}

resource "vault_jwt_auth_backend_role" "vault-admin" {
  backend = vault_jwt_auth_backend.oidc.path

  role_name = "vault-admin"
  role_type = "oidc"

  allowed_redirect_uris = [
    "https://vault.ssang.io/ui/vault/auth/oidc/oidc/callback",
    "http://localhost:8250/oidc/callback"
  ]

  user_claim = "sub"
  bound_claims = {
    groups = "vault-admin"
  }

  token_policies = [
    vault_policy.vault-admin.name
  ]
  token_ttl = 86400
}

resource "vault_policy" "vault-admin" {
  name = "vault-admin"

  policy = <<EOT
# Read system health check
path "sys/health"
{
  capabilities = ["read", "sudo"]
}

# Create and manage ACL policies broadly across Vault

# List existing policies
path "sys/policies/acl"
{
  capabilities = ["list"]
}

# Create and manage ACL policies
path "sys/policies/acl/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Enable and manage authentication methods broadly across Vault

# Manage auth methods broadly across Vault
path "auth/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Create, update, and delete auth methods
path "sys/auth/*"
{
  capabilities = ["create", "update", "delete", "sudo"]
}

# List auth methods
path "sys/auth"
{
  capabilities = ["read"]
}

# Enable and manage the key/value secrets engine at `secret/` path

# List, create, update, and delete key/value secrets
path "secret/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Manage secrets engines
path "sys/mounts/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# List existing secrets engines.
path "sys/mounts"
{
  capabilities = ["read"]
}
EOT
}

resource "vault_mount" "pki" {
  path = "pki"
  type = "pki"
  
  default_lease_ttl_seconds = 315360000
  max_lease_ttl_seconds = 315360000
}

resource "vault_pki_secret_backend_config_urls" "root" {
  backend = vault_mount.pki.path
  issuing_certificates = [
    "https://vault.ssang.io/v1/pki/ca",
  ]
  crl_distribution_points = [
    "https://vault.ssang.io/v1/pki/crl",
  ]
}

resource "vault_pki_secret_backend_root_cert" "this" {
  backend = vault_mount.pki.path
  type = "internal"
  common_name = "Vault Root CA"
}

resource "vault_pki_secret_backend_role" "root" {
  backend = vault_mount.pki.path
  name = "default"
  allow_any_name = true
}

resource "vault_mount" "pki_int" {
  path = "pki_int"
  type = "pki"
  
  default_lease_ttl_seconds = 31536000
  max_lease_ttl_seconds = 31536000
}

resource "vault_pki_secret_backend_config_urls" "intermediate" {
  backend = vault_mount.pki_int.path
  issuing_certificates = [
    "https://vault.ssang.io/v1/pki_int/ca",
  ]
  crl_distribution_points = [
    "https://vault.ssang.io/v1/pki_int/crl",
  ]
}

resource "vault_pki_secret_backend_intermediate_cert_request" "this" {
  backend = vault_mount.pki_int.path
  type = "internal"
  common_name = "Vault intermediate CA"
}

resource "vault_pki_secret_backend_root_sign_intermediate" "this" {
  backend = vault_mount.pki.path
  csr = vault_pki_secret_backend_intermediate_cert_request.this.csr
  common_name = vault_pki_secret_backend_intermediate_cert_request.this.common_name
}

resource "vault_pki_secret_backend_intermediate_set_signed" "this" {
  backend = vault_mount.pki_int.path
  certificate = vault_pki_secret_backend_root_sign_intermediate.this.certificate
}

resource "vault_pki_secret_backend_role" "intermediate" {
  backend = vault_mount.pki_int.path
  name = "default"
  allow_any_name = true
}

resource "vault_pki_secret_backend_cert" "elasticsearch" {
  backend = vault_mount.pki_int.path
  name = vault_pki_secret_backend_role.intermediate.name

  common_name = "Elasticsearch"
}

resource "vault_pki_secret_backend_cert" "kibana" {
  backend = vault_mount.pki_int.path
  name = vault_pki_secret_backend_role.intermediate.name

  common_name = "Kibana"
}