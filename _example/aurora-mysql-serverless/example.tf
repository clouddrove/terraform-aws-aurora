# Valid values for scaling config of mysql are - [1, 2, 4, 8, 16, 32, 64, 128, 256]

provider "aws" {
  region = "eu-west-1"
}

module "vpc" {
  source = "git::https://github.com/clouddrove/terraform-aws-vpc.git?ref=tags/0.12.5"

  name        = "vpc"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "application", "name"]

  cidr_block = "172.16.0.0/16"
}

module "subnets" {
  source = "git::https://github.com/clouddrove/terraform-aws-subnet.git?ref=tags/0.12.6"

  name        = "subnet"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "application", "name"]

  availability_zones  = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  vpc_id              = module.vpc.vpc_id
  cidr_block          = module.vpc.vpc_cidr_block
  type                = "public-private"
  nat_gateway_enabled = true
  igw_id              = module.vpc.igw_id
}

module "security_group" {
  source = "git::https://github.com/clouddrove/terraform-aws-security-group.git?ref=tags/0.12.4"

  name        = "aurora-mysql-sg"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "application", "name"]

  vpc_id        = module.vpc.vpc_id
  allowed_ip    = ["172.16.0.0/16"]
  allowed_ports = [3306]
}

module "kms_key" {
    source      = "git::https://github.com/clouddrove/terraform-aws-kms.git?ref=tags/0.12.5"
    
    name        = "kms"
    application = "clouddrove"
    environment = "test"
    label_order = ["environment", "application", "name"]
    enabled     = true
    
    description              = "KMS key for aurora"
    alias                    = "alias/aurora"
    key_usage                = "ENCRYPT_DECRYPT"
    customer_master_key_spec = "SYMMETRIC_DEFAULT"
    deletion_window_in_days  = 7
    is_enabled               = true
    enable_key_rotation      = false
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
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "application", "name"]

  enable                          = true
  serverless_enabled              = true
  min_capacity                    = 1   
  max_capacity                    = 4
  username                        = "root"
  database_name                   = "test_db"
  engine                          = "aurora"
  engine_version                  = "5.6.10a"
  kms_key_id                      = module.kms_key.key_arn
  subnets                         = module.subnets.private_subnet_id
  aws_security_group              = [module.security_group.security_group_ids]
  apply_immediately               = true
  skip_final_snapshot             = true
  availability_zones              = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}