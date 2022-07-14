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
    size       = "s-2vcpu-4gb"
    auto_scale = true
    min_nodes  = 1
    max_nodes  = 3
  }

  maintenance_policy {
    start_time = "00:00"
    day        = "sunday"
  }
}

# module "eks" {
#   source = "terraform-aws-modules/eks/aws"
#   version = "18.26.3"

#   cluster_name = "ssang"
#   cluster_version = "1.22"

#   cluster_endpoint_private_access = true
#   cluster_endpoint_public_access = true

#   cluster_addons = {
#     coredns = {
#       resolve_conflicts = "OVERWRITE"
#     }
#     kube-proxy = {}
#     vpc-cni = {
#       resolve_conflicts = "OVERWRITE"
#     }
#   }

#   vpc_id = module.vpc.vpc_id
#   subnet_ids = module.vpc.public_subnets

#   eks_managed_node_group_defaults = {
#     disk_size = 30
#     instance_types = [ "t3a.small", "t3.small" ]
#   }

#   eks_managed_node_groups = {
#     default = {}
#   }

#   # managed_aws_auth_configmap = true
# }