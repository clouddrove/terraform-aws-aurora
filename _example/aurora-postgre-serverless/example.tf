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
  version = "1.3.1"

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
  version = "1.3.0"

  name        = "public-subnet"
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

##-----------------------------------------------------
## An AWS security group acts as a virtual firewall for incoming and outgoing traffic.
##-----------------------------------------------------
module "security_group" {
  source  = "clouddrove/security-group/aws"
  version = "1.3.0"

  name        = "aurora-postgresql-sg"
  environment = "test"
  label_order = ["environment", "name"]

  vpc_id        = module.vpc.vpc_id
  allowed_ip    = ["172.16.0.0/16"]
  allowed_ports = [5432]
}

##-----------------------------------------------------
## AWS Key Management Service (KMS) gives you centralized control over the cryptographic keys used to protect your data.
##-----------------------------------------------------
module "kms_key" {
  source  = "clouddrove/kms/aws"
  version = "1.3.0"

  name        = "kms"
  environment = "test"
  label_order = ["environment", "name"]
  enabled     = true

  description              = "KMS key for aurora"
  alias                    = "alias/aurora"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days  = 7
  is_enabled               = true
  policy                   = data.aws_iam_policy_document.default.json
}

data "aws_iam_policy_document" "default" {
  version = "2012-10-17"

  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }
}

##-----------------------------------------------------------------------------
## aurora_postgresql module call.
##-----------------------------------------------------------------------------
module "aurora_postgresql" {
  source = "./../../"

  name        = "aurora-postgresql-serverless"
  environment = "test"
  label_order = ["environment", "name"]

  enable                              = true
  serverless_enabled                  = true
  min_capacity                        = 2
  max_capacity                        = 4
  username                            = "root"
  database_name                       = "test_db"
  engine                              = "aurora-postgresql"
  engine_version                      = "10.7"
  kms_key_id                          = module.kms_key.key_arn
  subnets                             = module.subnets.private_subnet_id
  aws_security_group                  = [module.security_group.security_group_ids]
  apply_immediately                   = true
  skip_final_snapshot                 = true
  availability_zones                  = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  enabled_cloudwatch_logs_exports     = ["postgresql", "upgrade", "general", "audit"]
  iam_database_authentication_enabled = false
  monitoring_interval                 = "0"
}
