output "keycloak_role_password" {
  value = postgresql_role.keycloak.password

  sensitive = true
}