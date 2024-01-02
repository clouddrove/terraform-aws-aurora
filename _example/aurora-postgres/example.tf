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
  source  = "clouddrove/vpc/aws"
  version = "2.0.0"

  name        = local.name
  environment = local.environment
  label_order = local.label_order

  cidr_block = "10.10.0.0/16"
}

##------------------------------------------------------------------------------
## A subnet is a range of IP addresses in your VPC.
##-----------------------------------------------------------------------------
#tfsec:ignore:aws-ec2-no-excessive-port-access  # All ports are allowed by default but can be changed via variables.
#tfsec:ignore:aws-ec2-no-public-ingress-acl  # Public ingress is allowed from all network but can be restricted by using variables.
module "subnets" {
  source = "clouddrove/subnet/aws"

  name        = local.name
  environment = local.environment
  label_order = local.label_order

  nat_gateway_enabled = true
  single_nat_gateway  = true
  availability_zones  = ["${local.region}a", "${local.region}b", "${local.region}c"]
  vpc_id              = module.vpc.vpc_id
  type                = "public-private"
  igw_id              = module.vpc.igw_id
  cidr_block          = module.vpc.vpc_cidr_block
  ipv6_cidr_block     = module.vpc.ipv6_cidr_block
  enable_ipv6         = false
  private_inbound_acl_rules = [{
    rule_number = 100
    rule_action = "allow"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_block  = module.vpc.vpc_cidr_block
  }]
  private_outbound_acl_rules = [{
    rule_number = 100
    rule_action = "allow"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_block  = module.vpc.vpc_cidr_block
  }]
}

##-----------------------------------------------------------------------------
## SECURITY GROUP: For RDS Proxy
##-----------------------------------------------------------------------------
module "proxy_sg" {
  source  = "clouddrove/security-group/aws"
  version = "2.0.0"

  name        = "${local.name}-proxy"
  environment = local.environment

  vpc_id = module.vpc.vpc_id
  new_sg_ingress_rules_with_cidr_blocks = [{
    rule_count  = 1
    from_port   = 5432
    protocol    = "tcp"
    to_port     = 5432
    cidr_blocks = [module.vpc.vpc_cidr_block]
    description = "Allow all traffic from VPC."
  }]
  new_sg_egress_rules_with_cidr_blocks = [{
    rule_count       = 1
    from_port        = 0
    protocol         = "-1"
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "Allow all outbound traffic."
  }]
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
  subnets         = module.subnets.private_subnet_id
  allowed_ip      = [module.vpc.vpc_cidr_block]
  instances = {
    1 = {
      instance_class      = "db.t4g.medium"
      publicly_accessible = false
    }
  }
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
  create_db_proxy  = true
  engine_family    = "POSTGRESQL"
  proxy_subnet_ids = module.subnets.private_subnet_id
  proxy_sg_ids     = [module.proxy_sg.security_group_id]
  auth = [
    {
      auth_scheme = "SECRETS"
      description = "example"
      iam_auth    = "DISABLED"
      secret_arn  = module.aurora.cluster_master_user_secret[0].secret_arn
    }
  ]
}

##-----------------------------------------------------------------------------
## EC2: To connect to RDS via rds-proxy
##-----------------------------------------------------------------------------
module "ec2_sg" {
  source  = "clouddrove/security-group/aws"
  version = "2.0.0"

  name        = "${local.name}-instance"
  environment = local.environment

  vpc_id = module.vpc.vpc_id
  new_sg_ingress_rules_with_cidr_blocks = [
    {
      rule_count  = 1
      from_port   = 22
      protocol    = "tcp"
      to_port     = 22
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow SSH traffic from anywhere."
    },
    {
      rule_count  = 2
      from_port   = 5432
      protocol    = "tcp"
      to_port     = 5432
      cidr_blocks = [module.vpc.vpc_cidr_block]
      description = "Allow PostgreSQL traffic from VPC."
    }
  ]
  new_sg_egress_rules_with_cidr_blocks = [
    {
      rule_count       = 1
      from_port        = 0
      protocol         = "-1"
      to_port          = 0
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      description      = "Allow all outbound traffic."
    }
  ]
}

module "ec2" {
  source  = "clouddrove/ec2/aws"
  version = "2.0.1"

  name        = "${local.name}-instance"
  environment = local.environment
  label_order = local.label_order

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.subnets.public_subnet_id
  sg_ids     = [module.ec2_sg.security_group_id]

  instance_count              = 1
  ami                         = "ami-0c7217cdde317cfec"
  instance_type               = "t2.micro"
  public_key                  = ""
  associate_public_ip_address = true
  assign_eip_address          = false
  monitoring                  = false
  instance_profile_enabled    = true
  instance_tags               = {}
  root_block_device = [{
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
  }]
}