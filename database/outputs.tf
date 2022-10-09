output "keycloak_role_password" {
  value = postgresql_role.keycloak.password

  sensitive = true
}

output "backstage_role_password" {
  value = postgresql_role.backstage.password

  sensitive = true
}