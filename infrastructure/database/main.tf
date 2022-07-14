module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "4.5.0"

  identifier = "ssang"

  username = "postgres"

  engine            = "postgres"
  engine_version    = "14.2"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  iam_database_authentication_enabled = true

  vpc_security_group_ids = [ module.rds-sg.security_group_id ]

  create_db_subnet_group = true
  subnet_ids             = var.public_subnets

  family = "postgres14"

  providers = {
    aws = aws.free-tier
  }
}

module "rds-sg" {
  source  = "terraform-aws-modules/security-group/aws//modules/postgresql"
  version = "4.9.0"

  name        = "postgres"
  description = "postgres"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = var.ingress_cidr_blocks

  providers = {
    aws = aws.free-tier
  }
}