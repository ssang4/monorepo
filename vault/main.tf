resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "this" {
  backend = vault_auth_backend.kubernetes.path

  kubernetes_host = var.kubernetes_host
  
  disable_iss_validation = true
}

resource "vault_kubernetes_auth_backend_role" "backstage" {
  backend = vault_auth_backend.kubernetes.path
  role_name = "backstage"

  bound_service_account_names = [ "backstage" ]
  bound_service_account_namespaces = [ "backstage" ]

  token_policies = [ vault_policy.backstage.name ]
}

resource "vault_policy" "backstage" {
  name = "read-backtage-secrets"

  policy = <<EOT
path "secret/data/backstage"  {
  capabilities = [ "read" ]
}
EOT
}

resource "vault_kubernetes_auth_backend_role" "external-dns" {
  backend = vault_auth_backend.kubernetes.path
  role_name = "external-dns"

  bound_service_account_names = [ "external-dns" ]
  bound_service_account_namespaces = [ "external-dns" ]

  token_policies = [ vault_policy.external-dns.name ]
}

resource "vault_policy" "external-dns" {
  name = "read-external-dns-secrets"

  policy = <<EOT
path "secret/data/external-dns"  {
  capabilities = [ "read" ]
}
EOT
}

resource "vault_kubernetes_auth_backend_role" "eso" {
  backend = vault_auth_backend.kubernetes.path
  role_name = "eso"

  bound_service_account_names = [ "eso" ]
  bound_service_account_namespaces = [ "eso" ]

  token_policies = [ vault_policy.eso.name ]
}

resource "vault_policy" "eso" {
  name = "read-all-secrets"

  policy = <<EOT
path "secret/*"  {
  capabilities = [ "read" ]
}
EOT
}

resource "vault_mount" "kvv2" {
  path = "secret"
  type = "kv"

  options = {
    version = "2"
  }
}

resource "vault_aws_secret_backend" "this" {
  access_key = "AKIAQKDMYHM2DJ7ZKTX2"
  region = "eu-central-1"
}