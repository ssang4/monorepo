module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"

  cidr = "10.0.0.0/16"

  azs = [ "eu-central-1a", "eu-central-1b", "eu-central-1c" ]
  private_subnets = [ "10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24" ]
  public_subnets = [ "10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24" ]

  enable_nat_gateway = false
}

module "vpc-free-tier" {
  source = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"

  cidr = "172.16.0.0/16"

  azs = [ "eu-central-1a", "eu-central-1b", "eu-central-1c" ]
  private_subnets = [ "172.16.1.0/24", "172.16.2.0/24", "172.16.3.0/24" ]
  public_subnets = [ "172.16.10.0/24", "172.16.20.0/24", "172.16.30.0/24" ]

  enable_nat_gateway = false

  providers = {
    aws = aws.free-tier
   }
}