data "digitalocean_kubernetes_versions" "this" {
  version_prefix = "1.22."
}

resource "digitalocean_kubernetes_cluster" "this" {
  name         = "ssang"
  region       = "fra1"
  version      = data.digitalocean_kubernetes_versions.this.latest_version
  auto_upgrade = true

  node_pool {
    name       = "default"
    size       = "s-1vcpu-2gb"
    auto_scale = true
    min_nodes  = 1
    max_nodes  = 3
  }

  maintenance_policy {
    start_time = "00:00"
    day        = "sunday"
  }
}