provider "aws" {
  region = local.region
}

locals {
  name        = "aurora-postgres"
  environment = "test"
  label_order = ["environment", "name"]
  region      = "us-east-1"
}
##-----------------------------------------------------------------------------
## A VPC is a virtual network that closely resembles a traditional network that you'd operate in your own data center.
##-----------------------------------------------------------------------------
module "vpc" {
  source      = "clouddrove/vpc/aws"
  version     = "2.0.0"
  name        = local.name
  environment = local.environment
  cidr_block  = "172.16.0.0/16"
}

##------------------------------------------------------------------------------
## A subnet is a range of IP addresses in your VPC.
##-----------------------------------------------------------------------------
#tfsec:ignore:aws-ec2-no-excessive-port-access  # All ports are allowed by default but can be changed via variables.
#tfsec:ignore:aws-ec2-no-public-ingress-acl  # Public ingress is allowed from all network but can be restricted by using variables.
# module "subnets" {
#   source             = "clouddrove/subnet/aws"
#   version            = "2.0.1"
#   name               = local.name
#   environment        = local.environment
#   availability_zones = ["${local.region}b", "${local.region}c"]
#   vpc_id             = module.vpc.vpc_id
#   cidr_block         = module.vpc.vpc_cidr_block
#   ipv6_cidr_block    = module.vpc.ipv6_cidr_block
#   type               = "private"
#   igw_id             = module.vpc.igw_id
# }


module "private-subnets" {
  source              = "clouddrove/subnet/aws"
  name                = local.name
  environment         = local.environment
  nat_gateway_enabled = true
  availability_zones  = ["us-east-1a", "us-east-1b", "us-east-1c"]
  vpc_id              = module.vpc.vpc_id
  type                = "private"
  cidr_block          = module.vpc.vpc_cidr_block
  ipv6_cidr_block     = module.vpc.ipv6_cidr_block
  public_subnet_ids   = module.private-subnets.private_subnet_id

}



##-----------------------------------------------------------------------------
## RDS Aurora Module
##-----------------------------------------------------------------------------
module "aurora" {
  source          = "../../"
  name            = local.name
  environment     = local.environment
  engine          = "aurora-postgresql"
  engine_version  = "14.7"
  master_username = "root"
  storage_type    = "aurora-iopt1"
  sg_ids          = []
  allowed_ports   = [5432]
  # subnets         = module.private-subnets.public_subnet_id
  subnets    = module.private-subnets.private_subnet_id #changes
  allowed_ip = [module.vpc.vpc_cidr_block]
  instances = {
    1 = {
      instance_class      = "db.t4g.medium"
      publicly_accessible = false
    }
  }
  # endpoints = {
  #   static = {
  #     identifier     = "static-custom-endpt"
  #     type           = "ANY"
  #     static_members = ["static-member-1"]
  #     tags           = { Endpoint = "static-members" }
  #   }
  #   excluded = {
  #     identifier       = "excluded-custom-endpt"
  #     type             = "READER"
  #     excluded_members = ["excluded-member-1"]
  #     tags             = { Endpoint = "excluded-members" }
  #   }
  # }
  vpc_id        = module.vpc.vpc_id
  database_name = "postgres"

  apply_immediately                      = true
  skip_final_snapshot                    = true
  create_db_cluster_parameter_group      = true
  db_cluster_parameter_group_name        = "aurora-postgre"
  db_cluster_parameter_group_family      = "aurora-postgresql14"
  db_cluster_parameter_group_description = "aurora postgres example cluster parameter group"
  db_cluster_parameter_group_parameters = [
    {
      name         = "log_min_duration_statement"
      value        = 4000
      apply_method = "immediate"
      }, {
      name         = "rds.force_ssl"
      value        = 1
      apply_method = "immediate"
    }
  ]
  create_db_parameter_group      = true
  db_parameter_group_name        = "aurora-postgre"
  db_parameter_group_family      = "aurora-postgresql14"
  db_parameter_group_description = "postgres aurora example DB parameter group"
  db_parameter_group_parameters = [
    {
      name         = "log_min_duration_statement"
      value        = 4000
      apply_method = "immediate"
    }
  ]
  enabled_cloudwatch_logs_exports = ["postgresql"]
  create_cloudwatch_log_group     = false


  ##-------------------------------------
  ## RDS PROXY
  ##-------------------------------------
  create_db_proxy = true
  engine_family   = "POSTGRESQL"
  # proxy_subnet_ids = module.private-subnets.public_subnet_id
  proxy_subnet_ids = module.private-subnets.private_subnet_id
  auth = [
    {
      auth_scheme = "SECRETS"
      description = "example"
      iam_auth    = "DISABLED"
      secret_arn  = module.aurora.cluster_master_user_secret[0].secret_arn #<--- MAKE IT DYNAMIC
    }
  ]
}
