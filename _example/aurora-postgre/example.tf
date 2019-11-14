provider "aws" {
  region = "eu-west-1"
}

module "vpc" {
  source = "git::https://github.com/clouddrove/terraform-aws-vpc.git?ref=tags/0.12.4"

  name        = "vpc"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "name", "application"]

  cidr_block = "172.16.0.0/16"
}

module "public_subnets" {
  source = "git::https://github.com/clouddrove/terraform-aws-subnet.git?ref=tags/0.12.3"

  name        = "public-subnet"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "name", "application"]

  availability_zones = ["eu-west-1b", "eu-west-1c"]
  vpc_id             = module.vpc.vpc_id
  cidr_block         = module.vpc.vpc_cidr_block
  type               = "public"
  igw_id             = module.vpc.igw_id
}

module "security-group" {
  source = "git::https://github.com/clouddrove/terraform-aws-security-group.git?ref=tags/0.12.2"

  name        = "postgres-sg"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "name", "application"]

  vpc_id        = module.vpc.vpc_id
  allowed_ip    = ["172.16.0.0/16", "10.0.0.0/16", "115.160.246.74/32"]
  allowed_ports = [3306]
}

module "postgres" {
  source = "git::https://github.com/clouddrove/terraform-aws-aurora.git?ref=tags/0.12.1"

  name        = "backend"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "name", "application"]

  username            = "root"
  database_name       = "test_db"
  engine              = "aurora-postgresql"
  engine_version      = "9.6.9"
  subnets             = tolist(module.public_subnets.public_subnet_id)
  aws_security_group  = [module.security-group.security_group_ids]
  replica_count       = 1
  instance_type       = "db.r4.large"
  apply_immediately   = true
  skip_final_snapshot = true
  publicly_accessible = false
}
