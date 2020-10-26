# Managed By  : CloudDrove
# Description : This Script is used to create DB Subnet, Rendom Password, RDS cluster and Parameter Groups.
# Copyright @ CloudDrove. All Right Reserved.

#Module      : Label
#Description : This terraform module is designed to generate consistent label names and
#              tags for resources. You can use terraform-labels to implement a strict
#              naming convention.
module "labels" {
  source = "git::https://github.com/clouddrove/terraform-labels.git?ref=tags/0.12.0"

  name        = var.name
  application = var.application
  environment = var.environment
  managedby   = var.managedby
  label_order = var.label_order
}

locals {
  port            = var.port == "" ? var.engine == "aurora-postgresql" ? "5432" : "3306" : var.port
  master_password = var.password == "" ? random_id.master_password.b64_url : var.password
}

# Random string to use as master password unless one is specified
resource "random_id" "master_password" {
  byte_length = 20
}

#Module      : DB SUBNET GROUP
#Description : Provides an RDS DB subnet group resource.
resource "aws_db_subnet_group" "default" {
  count = var.enable == true && var.enabled_subnet_group == true ? 1 : 0

  name        = module.labels.id
  description = format("For Aurora cluster %s", module.labels.id)
  subnet_ids  = var.subnets
  tags        = module.labels.tags
}

#Module      : RDS AURORA CLUSTER
#Description : Terraform module which creates RDS Aurora database resources on AWS and can
#              create different type of databases. Currently it supports Postgres and MySQL.
resource "aws_rds_cluster" "default" {
  count = var.enable == true && var.enabled_rds_cluster == true && var.serverless_enabled == false ? 1 : 0

  cluster_identifier                  = module.labels.id
  engine                              = var.engine
  engine_version                      = var.engine_version
  kms_key_id                          = var.kms_key_id
  database_name                       = var.database_name
  master_username                     = var.username
  master_password                     = local.master_password
  final_snapshot_identifier           = format("%s-%s-%s", var.final_snapshot_identifier_prefix, module.labels.id, random_id.snapshot_identifier.hex)
  skip_final_snapshot                 = var.skip_final_snapshot
  deletion_protection                 = var.deletion_protection
  backup_retention_period             = var.backup_retention_period
  preferred_backup_window             = var.preferred_backup_window
  preferred_maintenance_window        = var.preferred_maintenance_window
  port                                = local.port
  db_subnet_group_name                = join("", aws_db_subnet_group.default.*.name)
  vpc_security_group_ids              = var.aws_security_group
  snapshot_identifier                 = var.snapshot_identifier
  storage_encrypted                   = var.storage_encrypted
  apply_immediately                   = var.apply_immediately
  copy_tags_to_snapshot               = var.copy_tags_to_snapshot
  enabled_cloudwatch_logs_exports     = var.enabled_cloudwatch_logs_exports
  db_cluster_parameter_group_name     = var.engine == "aurora-postgresql" ? aws_rds_cluster_parameter_group.postgresql.*.id[0] : aws_rds_cluster_parameter_group.aurora.*.id[0]
  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  tags = module.labels.tags
}

#Module      : RDS CLUSTER INSTANCE
#Description : Terraform module which creates RDS Aurora database resources on AWS and can
#              create different type of databases. Currently it supports Postgres and MySQL.
resource "aws_rds_cluster_instance" "default" {
  count = var.enable == true && var.serverless_enabled == false ? (var.replica_scale_enabled ? var.replica_scale_min : var.replica_count) : 0

  identifier                      = var.enable == true ? format("%s-%s", module.labels.id, (count.index + 1)) : ""
  cluster_identifier              = element(aws_rds_cluster.default.*.id, count.index)
  engine                          = var.engine
  engine_version                  = var.engine_version
  instance_class                  = var.instance_type
  publicly_accessible             = var.publicly_accessible
  db_subnet_group_name            = join("", aws_db_subnet_group.default.*.name)
  db_parameter_group_name         = var.enable == true && var.engine == "aurora-postgresql" ? aws_db_parameter_group.postgresql.*.id[0] : aws_db_parameter_group.aurora.*.id[0]
  preferred_maintenance_window    = var.preferred_maintenance_window
  apply_immediately               = var.apply_immediately
  monitoring_interval             = var.monitoring_interval
  auto_minor_version_upgrade      = var.auto_minor_version_upgrade
  promotion_tier                  = count.index + 1
  performance_insights_enabled    = var.performance_insights_enabled
  performance_insights_kms_key_id = var.performance_insights_kms_key_id

  tags = module.labels.tags
}

resource "random_id" "snapshot_identifier" {
  keepers = {
    id = module.labels.id
  }
  byte_length = 4
}

resource "aws_db_parameter_group" "postgresql" {
  count = var.enable == true && var.engine == "aurora-postgresql" && var.serverless_enabled == false ? 1 : 0

  name        = module.labels.id
  family      = var.postgresql_family
  description = format("Parameter group for %s", module.labels.id)
}

resource "aws_rds_cluster_parameter_group" "postgresql" {
  count = var.enable == true && var.engine == "aurora-postgresql" && var.serverless_enabled == false ? 1 : 0

  name        = format("%s-cluster", module.labels.id)
  family      = var.postgresql_family
  description = format("Cluster parameter group for %s", module.labels.id)
}

resource "aws_db_parameter_group" "aurora" {
  count = var.enable == true && var.engine == "aurora-mysql" && var.serverless_enabled == false ? 1 : 0

  name        = module.labels.id
  family      = var.mysql_family
  description = format("Parameter group for %s", module.labels.id)
}

resource "aws_rds_cluster_parameter_group" "aurora" {
  count = var.enable == true && var.engine == "aurora-mysql" && var.serverless_enabled == false ? 1 : 0

  name        = format("%s-cluster", module.labels.id)
  family      = var.mysql_family
  description = format("Cluster parameter group for %s", module.labels.id)
}

resource "aws_rds_cluster_parameter_group" "postgresql_serverless" {
  count = var.enable && var.engine == "aurora-postgresql" ? 1 : 0

  name        = format("%s-serverless-cluster", module.labels.id)
  family      = var.postgresql_family_serverless
  description = format("Cluster parameter group for %s Postgresql Serverless", module.labels.id)
}

resource "aws_rds_cluster_parameter_group" "aurora_serverless" {
  count = var.enable && var.engine == "aurora" ? 1 : 0

  name        = format("%s-serverless-cluster", module.labels.id)
  family      = var.mysql_family_serverless
  description = format("Cluster parameter group for %s MySQL ", module.labels.id)
}

#Module      : RDS SERVERLESS CLUSTER
#Description : Terraform module which creates RDS Aurora serverless database resources on AWS and can
#              create different type of databases. Currently it supports Postgres and MySQL.
resource "aws_rds_cluster" "serverless" {
  count = var.enable && var.enabled_rds_cluster && var.serverless_enabled ? 1 : 0

  cluster_identifier                  = module.labels.id
  engine                              = var.engine
  engine_version                      = var.engine_version
  engine_mode                         = var.engine_mode
  kms_key_id                          = var.kms_key_id
  database_name                       = var.database_name
  master_username                     = var.username
  master_password                     = local.master_password
  backtrack_window                    = var.backtrack_window
  replication_source_identifier       = var.replication_source_identifier
  final_snapshot_identifier           = format("%s-%s-%s", var.final_snapshot_identifier_prefix, module.labels.id, random_id.snapshot_identifier.hex)
  skip_final_snapshot                 = var.skip_final_snapshot
  deletion_protection                 = var.deletion_protection
  backup_retention_period             = var.backup_retention_period
  preferred_backup_window             = var.preferred_backup_window
  preferred_maintenance_window        = var.preferred_maintenance_window
  port                                = local.port
  iam_roles                           = var.iam_roles
  source_region                       = var.source_region
  db_subnet_group_name                = join("", aws_db_subnet_group.default.*.name)
  vpc_security_group_ids              = var.aws_security_group
  snapshot_identifier                 = var.snapshot_identifier
  storage_encrypted                   = var.storage_encrypted
  apply_immediately                   = var.apply_immediately
  copy_tags_to_snapshot               = var.copy_tags_to_snapshot
  db_cluster_parameter_group_name     = var.engine == "aurora-postgresql" ? aws_rds_cluster_parameter_group.postgresql_serverless.*.id[0] : aws_rds_cluster_parameter_group.aurora_serverless.*.id[0]
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  availability_zones                  = var.availability_zones
  enable_http_endpoint                = var.enable_http_endpoint

  scaling_configuration {
    auto_pause               = var.auto_pause
    max_capacity             = var.max_capacity
    min_capacity             = var.min_capacity
    seconds_until_auto_pause = var.seconds_until_auto_pause
    timeout_action           = var.timeout_action
  }

  tags = module.labels.tags
}
