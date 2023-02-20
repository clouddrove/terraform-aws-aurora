# Valid values for scaling config of mysql are - [1, 2, 4, 8, 16, 32, 64, 128, 256]

provider "aws" {
  region = "eu-west-1"
}

module "vpc" {
  source  = "clouddrove/vpc/aws"
  version = "1.3.0"

  name        = "vpc"
  environment = "test"
  label_order = ["name", "environment"]

  cidr_block = "172.16.0.0/16"
}

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

module "security_group" {
  source  = "clouddrove/security-group/aws"
  version = "1.3.0"
  name    = "aurora-mysql-sg"

  environment = "test"
  label_order = ["name", "environment"]

  vpc_id        = module.vpc.vpc_id
  allowed_ip    = ["172.16.0.0/16"]
  allowed_ports = [3306]
}

module "kms_key" {
  source      = "clouddrove/kms/aws"
  version     = "1.3.0"
  name        = "kms"
  environment = "test"
  label_order = ["name", "environment"]

  enabled = true

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

module "aurora_mysql" {
  source = "./../../"

  name        = "aurora-mysql-serverless"
  environment = "test"
  label_order = ["name", "environment"]


  enable                              = true
  serverless_enabled                  = true
  min_capacity                        = 1
  max_capacity                        = 4
  username                            = "root"
  database_name                       = "test_db"
  engine                              = "aurora"
  engine_version                      = "5.6.10a"
  kms_key_id                          = module.kms_key.key_arn
  subnets                             = module.subnets.private_subnet_id
  aws_security_group                  = [module.security_group.security_group_ids]
  enabled_cloudwatch_logs_exports     = ["audit", "error", "general", "slowquery"]
  apply_immediately                   = true
  skip_final_snapshot                 = true
  availability_zones                  = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  iam_database_authentication_enabled = false
  monitoring_interval                 = "0"
}
