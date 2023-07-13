##---------------------------------------------------------------------------------------------------------------------------
## Provider block added, Use the Amazon Web Services (AWS) provider to interact with the many resources supported by AWS.
##--------------------------------------------------------------------------------------------------------------------------
provider "aws" {
  region = "eu-west-1"
}

##---------------------------------------------------------------------------------------------------------------------------
## A VPC is a virtual network that closely resembles a traditional network that you'd operate in your own data center.
##--------------------------------------------------------------------------------------------------------------------------
module "vpc" {
  source  = "clouddrove/vpc/aws"
  version = "1.3.1"

  name        = "aurora-mysql"
  environment = "test"
  label_order = ["name", "environment"]
  cidr_block  = "172.16.0.0/16"
}

##------------------------------------------------------------------------------
## A subnet is a range of IP addresses in your VPC.
##------------------------------------------------------------------------------
module "public_subnets" {
  source      = "clouddrove/subnet/aws"
  version     = "1.3.0"
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

##------------------------------------------------------------------------------
## aurora module call.
##------------------------------------------------------------------------------
module "aurora" {
  source = "./../../"

  name        = "aurora"
  environment = "test"
  label_order = ["name", "environment"]

  ####------------------------------------------------------------------------
  ## Below A security group controls the traffic that is allowed to reach and leave the resources that it is associated with.
  ####------------------------------------------------------------------------
  vpc_id        = module.vpc.vpc_id
  allowed_ip    = [module.vpc.vpc_cidr_block]
  allowed_ports = [3306]

  enable                              = true
  username                            = "root"
  database_name                       = "test_db"
  engine                              = "aurora-mysql"
  engine_version                      = "8.0.mysql_aurora.3.02.0"
  subnets                             = tolist(module.public_subnets.public_subnet_id)
  replica_count                       = 1
  instance_type                       = "db.t4g.medium"
  performance_insights_enabled        = true
  apply_immediately                   = true
  publicly_accessible                 = false
  enabled_cloudwatch_logs_exports     = ["audit", "error", "general", "slowquery"]
  iam_database_authentication_enabled = false
  monitoring_interval                 = "5"

  ###ssm parameter
  ssm_parameter_endpoint_enabled = true
}
