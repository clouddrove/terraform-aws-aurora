provider "aws" {
  region = "eu-north-1"
}

locals {
  environment = "test"
  name        = "aurora-mysql-serverless"
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
## MySQL Serverless
##-----------------------------------------------------------------------------
module "aurora_mysql" {
  source               = "../../"
  name                 = local.name
  environment          = local.environment
  engine               = "aurora-mysql"
  engine_mode          = "provisioned"
  engine_version       = "8.0"
  master_username      = "root"
  database_name        = "test"
  sg_ids               = []
  allowed_ports        = [3306]
  allowed_ip           = [module.vpc.vpc_cidr_block]
  vpc_id               = module.vpc.vpc_id
  subnets              = module.subnets.public_subnet_id
  
  monitoring_interval = 60
  apply_immediately   = true
  skip_final_snapshot = true
  serverlessv2_scaling_configuration = {
    min_capacity = 2
    max_capacity = 10
  }
  instance_class = "db.serverless"
  instances = {
    one = {}
    two = {}
  }

}

