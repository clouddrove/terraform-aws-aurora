##---------------------------------------------------------------------------------------------------------------------------
## Provider block added, Use the Amazon Web Services (AWS) provider to interact with the many resources supported by AWS.
##--------------------------------------------------------------------------------------------------------------------------
provider "aws" {
  region = "eu-west-1"
}

##---------------------------------------------------------------------------------------------------------------------------
## A VPC is a virtual network that closely resembles a traditional network that you'd operate in your own data center.
##---------------------------------------------------------------------------------------------------------------------------
module "vpc" {
  source  = "clouddrove/vpc/aws"
  version = "2.0.0"

  name        = "vpc"
  environment = "test"
  label_order = ["environment", "name"]

  cidr_block = "172.16.0.0/16"
}

##-----------------------------------------------------
## A subnet is a range of IP addresses in your VPC.
##-----------------------------------------------------
module "subnets" {
  source  = "clouddrove/subnet/aws"
  version = "2.0.0"

  name        = "subnets"
  environment = "test"
  label_order = ["name", "environment"]

  availability_zones  = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  vpc_id              = module.vpc.vpc_id
  cidr_block          = module.vpc.vpc_cidr_block
  ipv6_cidr_block     = module.vpc.ipv6_cidr_block
  type                = "public-private"
  nat_gateway_enabled = true
  igw_id              = module.vpc.igw_id
}

##-----------------------------------------------------------------------------
## aurora_postgresql module call.
##-----------------------------------------------------------------------------
module "aurora_postgresql" {
  source = "./../../"

  name        = "postgresql-serverless"
  environment = "test"
  label_order = ["environment", "name"]

  enable                              = true
  serverless_enabled                  = true
  min_capacity                        = 2
  max_capacity                        = 4
  username                            = "root"
  database_name                       = "test_db"
  engine                              = "aurora-postgresql"
  engine_version                      = "13.7"
  instance_type                       = "db.r5.large"
  kms_key_id                          = ""
  subnets                             = module.subnets.private_subnet_id
  sg_ids                              = []
  apply_immediately                   = true
  skip_final_snapshot                 = true
  availability_zones                  = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  enabled_cloudwatch_logs_exports     = ["postgresql", "upgrade", "general", "audit"]
  iam_database_authentication_enabled = false
  monitoring_interval                 = "0"

  ####------------------------------------------------------------------------
  ## Below A security group controls the traffic that is allowed to reach and leave the resources that it is associated with.
  ####------------------------------------------------------------------------
  vpc_id        = module.vpc.vpc_id
  allowed_ip    = [module.vpc.vpc_cidr_block]
  allowed_ports = [5432]

  ###ssm parameter
  ssm_parameter_endpoint_enabled = false
}
