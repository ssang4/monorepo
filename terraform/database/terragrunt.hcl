include "root" {
  path = find_in_parent_folders()
}

dependency "networking" {
  config_path = "../networking"
}

inputs = {
  vpc_id = dependency.networking.outputs.vpc_id_free_tier
  public_subnets = dependency.networking.outputs.public_subnets_free_tier
  ingress_cidr_blocks = [
    dependency.networking.outputs.vpc_cidr_block,
    dependency.networking.outputs.vpc_free_tier_cidr_block
  ]
}