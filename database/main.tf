resource "random_password" "keycloak_role_password" {
  length = 16
}

resource "postgresql_role" "keycloak" {
  name     = "keycloak"
  password = random_password.keycloak_role_password.result
  login    = true
}

resource "postgresql_database" "keycloak" {
  name  = "keycloak"
  owner = postgresql_role.keycloak.id
}

resource "random_password" "backstage_role_password" {
  length = 16
}

resource "postgresql_role" "backstage" {
  name     = "backstage"
  password = random_password.keycloak_role_password.result
  login    = true
}

resource "postgresql_database" "backstage" {
  name  = "backstage"
  owner = postgresql_role.backstage.id
}