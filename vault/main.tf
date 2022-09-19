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

  kubernetes_host = "https://kubernetes.default.svc"
  disable_iss_validation = true
}

resource "vault_kubernetes_auth_backend_role" "cluster-secret-store" {
  backend = vault_auth_backend.kubernetes.path

  role_name = "cluster-secret-store"

  bound_service_account_namespaces = [ "external-secrets" ]
  bound_service_account_names = [ "cluster-secret-store" ]

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