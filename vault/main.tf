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