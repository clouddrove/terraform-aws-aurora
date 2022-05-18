provider "aws" {
  region = "eu-west-1"
}

module "vpc" {
  source  = "clouddrove/vpc/aws"
  version = "0.15.1"

  name        = "vpc"
  environment = "test"
  label_order = ["name", "environment"]

  cidr_block = "172.16.0.0/16"
}

module "public_subnets" {
  source  = "clouddrove/subnet/aws"
  version = "0.15.3"

  name        = "public-subnet"
  environment = "test"
  label_order = ["name", "environment"]

  availability_zones = ["eu-west-1b", "eu-west-1c"]
  vpc_id             = module.vpc.vpc_id
  cidr_block         = module.vpc.vpc_cidr_block
  ipv6_cidr_block    = module.vpc.ipv6_cidr_block
  type               = "public"
  igw_id             = module.vpc.igw_id
}

module "security-group" {
  source  = "clouddrove/security-group/aws"
  version = "1.0.1"

  name          = "postgres-sg"
  environment   = "test"
  label_order   = ["name", "environment"]
  vpc_id        = module.vpc.vpc_id
  allowed_ip    = ["172.16.0.0/16", "10.0.0.0/16", "115.160.246.74/32"]
  allowed_ports = [5432]
}

module "postgres" {
  source = "./../../"

  name        = "postgres"
  environment = "test"
  label_order = ["name", "environment"]

  username                            = "root"
  database_name                       = "test_db"
  engine                              = "aurora-postgresql"
  engine_version                      = "13.3"
  subnets                             = tolist(module.public_subnets.public_subnet_id)
  aws_security_group                  = [module.security-group.security_group_ids]
  enabled_cloudwatch_logs_exports     = ["postgresql"]
  replica_count                       = 1
  instance_type                       = "db.r5.large"
  apply_immediately                   = true
  skip_final_snapshot                 = true
  publicly_accessible                 = false
  iam_database_authentication_enabled = false
  monitoring_interval                 = "0"
}
