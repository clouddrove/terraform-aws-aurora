provider "aws" {
  region = "eu-west-1"
}

module "vpc" {
  source  = "clouddrove/vpc/aws"
  version = "0.15.0"

  name        = "aurora-mysql"
  repository  = "https://registry.terraform.io/modules/clouddrove/vpc/aws"
  environment = "test"
  label_order = ["name", "environment"]
  cidr_block  = "172.16.0.0/16"
}

module "public_subnets" {
  source      = "clouddrove/subnets/aws"
  version     = "0.15.0"
  name        = "public-subnet"
  repository  = "https://registry.terraform.io/modules/clouddrove/subnet/aws"
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
  version = "0.15.0"
  name    = "aurora-sg"

  repository    = "https://registry.terraform.io/modules/clouddrove/security-group/aws"
  environment   = "test"
  label_order   = ["name", "environment"]
  vpc_id        = module.vpc.vpc_id
  allowed_ip    = ["172.16.0.0/16", "10.0.0.0/16", "115.160.246.74/32"]
  allowed_ports = [3306]
}



module "aurora" {
  source = "./../../"

  name        = "auror"
  repository  = "https://registry.terraform.io/modules/clouddrove/aurora/aws"
  environment = "test"
  label_order = ["name", "environment"]

  enable                              = true
  username                            = "root"
  database_name                       = "test_db"
  engine                              = "aurora-mysql"
  engine_version                      = "5.7.12"
  subnets                             = tolist(module.public_subnets.public_subnet_id)
  aws_security_group                  = [module.security-group.security_group_ids]
  replica_count                       = 1
  instance_type                       = "db.t2.small"
  apply_immediately                   = true
  publicly_accessible                 = false
  enabled_cloudwatch_logs_exports     = ["audit", "error", "general", "slowquery"]
  iam_database_authentication_enabled = false
  monitoring_interval                 = "0"
}
