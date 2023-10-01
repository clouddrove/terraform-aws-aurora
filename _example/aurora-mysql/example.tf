provider "aws" {
  region = "eu-north-1"
}

locals {
  environment = "test"
  name        = "aurora-mysql"
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
##------------------------------------------------------------------------------
#tfsec:ignore:aws-ec2-no-excessive-port-access  # All ports are allowed by default but can be changed via variables.
#tfsec:ignore:aws-ec2-no-public-ingress-acl  # Public ingress is allowed from all network but can be restricted by using variables.
module "subnets" {
  source             = "clouddrove/subnet/aws"
  version            = "2.0.0"
  name               = local.name
  environment        = local.environment
  availability_zones = ["eu-north-1b", "eu-north-1c"]
  vpc_id             = module.vpc.vpc_id
  cidr_block         = module.vpc.vpc_cidr_block
  ipv6_cidr_block    = module.vpc.ipv6_cidr_block
  type               = "public"
  igw_id             = module.vpc.igw_id
}

##-----------------------------------------------------------------------------
## RDS Aurora Module
##-----------------------------------------------------------------------------
module "aurora" {
  source          = "../../"
  name            = local.name
  environment     = local.environment
  engine          = "aurora-mysql"
  engine_version  = "8.0"
  master_username = "root"
  database_name   = "test"
  sg_ids          = []
  allowed_ports   = [3306]
  allowed_ip      = [module.vpc.vpc_cidr_block]
  instances = {
    1 = {
      instance_class      = "db.r5.large"
      publicly_accessible = false
    }
    2 = {
      identifier     = "mysql-static-1"
      instance_class = "db.r5.2xlarge"
    }
    3 = {
      identifier     = "mysql-excluded-1"
      instance_class = "db.r5.xlarge"
      promotion_tier = 15
    }
  }

  vpc_id               = module.vpc.vpc_id

  apply_immediately   = true
  skip_final_snapshot = true
  subnets             = module.subnets.public_subnet_id

  create_db_cluster_parameter_group = true
  db_cluster_parameter_group_name   = "aurora-mysql"
  db_cluster_parameter_group_family = "aurora-mysql8.0"
  db_cluster_parameter_group_parameters = [
    {
      name         = "connect_timeout"
      value        = 120
      apply_method = "immediate"
      }, {
      name         = "innodb_lock_wait_timeout"
      value        = 300
      apply_method = "immediate"
      }, {
      name         = "log_output"
      value        = "FILE"
      apply_method = "immediate"
      }, {
      name         = "max_allowed_packet"
      value        = "67108864"
      apply_method = "immediate"
      }, {
      name         = "binlog_format"
      value        = "ROW"
      apply_method = "pending-reboot"
      }, {
      name         = "log_bin_trust_function_creators"
      value        = 1
      apply_method = "immediate"
      }, {
      name         = "require_secure_transport"
      value        = "ON"
      apply_method = "immediate"
      }, {
      name         = "tls_version"
      value        = "TLSv1.2"
      apply_method = "pending-reboot"
    }
  ]

  create_db_parameter_group      = true
  db_parameter_group_name        = "aurora-mysql"
  db_parameter_group_family      = "aurora-mysql8.0"
  db_parameter_group_description = "mysql aurora example DB parameter group"
  db_parameter_group_parameters = [
    {
      name         = "connect_timeout"
      value        = 60
      apply_method = "immediate"
      }, {
      name         = "general_log"
      value        = 0
      apply_method = "immediate"
      }, {
      name         = "innodb_lock_wait_timeout"
      value        = 300
      apply_method = "immediate"
      }, {
      name         = "long_query_time"
      value        = 5
      apply_method = "immediate"
      }, {
      name         = "max_connections"
      value        = 2000
      apply_method = "immediate"
      }, {
      name         = "slow_query_log"
      value        = 1
      apply_method = "immediate"
      }, {
      name         = "log_bin_trust_function_creators"
      value        = 1
      apply_method = "immediate"
    }
  ]

  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
  create_cloudwatch_log_group     = false
}

