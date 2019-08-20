provider "aws" {
  profile                 = "default"
  region                  = "us-east-1"
}

module "aurora" {
  source                          = "git::https://github.com/clouddrove/terraform-aws-aurora.git"
  organization                    = "clouddrove"
  environment                     = "dev"
  name                            = "backend"
  username                        = "admin"
  database_name                   = "dt"
  engine                          = "aurora-mysql"
  engine_version                  = "5.7.12"
  subnets                         = ["subnet-0399c34a","subnet-18d8ad35"]
  aws_security_group              = ["sg-042b5876d6decaae0"]
  replica_count                   = 1
  instance_type                   = "db.t2.medium"
  apply_immediately               = true
  skip_final_snapshot             = true
  publicly_accessible             = false
}


