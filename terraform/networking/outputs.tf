output "vpc_id" {
    value = module.vpc.vpc_id
}

output "private_subnets" {
    value = module.vpc.private_subnets
}

output "public_subnets" {
    value = module.vpc.public_subnets
}

output "vpc_id_free_tier" {
    value = module.vpc-free-tier.vpc_id
}

output "private_subnets_free_tier" {
    value = module.vpc-free-tier.private_subnets
}

output "public_subnets_free_tier" {
    value = module.vpc-free-tier.public_subnets
}