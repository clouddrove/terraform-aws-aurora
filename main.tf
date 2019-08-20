
module "label" {
  source      = "git::https://github.com/clouddrove/terraform-lables.git?ref=tags/0.11.0"
  name        = "${var.name}"
  application = "${var.application}"
  environment = "${var.environment}"
}
locals {
  port            = "${var.port == "" ? "${var.engine == "aurora-postgresql" ? "5432" : "3306"}" : var.port}"
  master_password = "${var.password == "" ? random_id.master_password.b64 : var.password}"
}

# Random string to use as master password unless one is specified
resource "random_id" "master_password" {
  byte_length = 21
}

resource "aws_db_subnet_group" "this" {
  name        = "${module.label.id}"
  description = "For Aurora cluster ${module.label.id}"
  subnet_ids  = ["${var.subnets}"]

  tags = "${merge(var.tags, map("Name", "aurora-${var.name}"))}"
}

resource "aws_rds_cluster" "this" {
  cluster_identifier                  = "${module.label.id}"
  engine                              = "${var.engine}"
  engine_version                      = "${var.engine_version}"
  kms_key_id                          = "${var.kms_key_id}"
  database_name                       = "${var.database_name}"
  master_username                     = "${var.username}"
  master_password                     = "${local.master_password}"
  final_snapshot_identifier           = "${var.final_snapshot_identifier_prefix}-${var.name}-${random_id.snapshot_identifier.hex}"
  skip_final_snapshot                 = "${var.skip_final_snapshot}"
  deletion_protection                 = "${var.deletion_protection}"
  backup_retention_period             = "${var.backup_retention_period}"
  preferred_backup_window             = "${var.preferred_backup_window}"
  preferred_maintenance_window        = "${var.preferred_maintenance_window}"
  port                                = "${local.port}"
  db_subnet_group_name                = "${aws_db_subnet_group.this.name}"
  vpc_security_group_ids              = ["${var.aws_security_group}"]
  snapshot_identifier                 = "${var.snapshot_identifier}"
  storage_encrypted                   = "${var.storage_encrypted}"
  apply_immediately                   = "${var.apply_immediately}"
  db_cluster_parameter_group_name     = "${aws_rds_cluster_parameter_group.aurora_cluster_parameter_group.id}"
  iam_database_authentication_enabled = "${var.iam_database_authentication_enabled}"

  tags = "${module.label.tags}"
}

resource "aws_rds_cluster_instance" "this" {
  count = "${var.replica_scale_enabled ? var.replica_scale_min : var.replica_count}"

  identifier                      = "${var.name}-${count.index + 1}"
  cluster_identifier              = "${aws_rds_cluster.this.id}"
  engine                          = "${var.engine}"
  engine_version                  = "${var.engine_version}"
  instance_class                  = "${var.instance_type}"
  publicly_accessible             = "${var.publicly_accessible}"
  db_subnet_group_name            = "${aws_db_subnet_group.this.name}"
  db_parameter_group_name         = "${aws_db_parameter_group.aurora_db_parameter_group.id}"
  preferred_maintenance_window    = "${var.preferred_maintenance_window}"
  apply_immediately               = "${var.apply_immediately}"
  monitoring_interval             = "${var.monitoring_interval}"
  auto_minor_version_upgrade      = "${var.auto_minor_version_upgrade}"
  promotion_tier                  = "${count.index + 1}"
  performance_insights_enabled    = "${var.performance_insights_enabled}"
  performance_insights_kms_key_id = "${var.performance_insights_kms_key_id}"

  tags = "${module.label.tags}"
}

resource "random_id" "snapshot_identifier" {
  keepers = {
    id = "${var.name}"
  }

  byte_length = 4
}
resource "aws_db_parameter_group" "aurora_db_parameter_group" {
  name        = "aurora-db-parameter-group"
  family      = "aurora-mysql5.7"
  description = "aurora-db-parameter-group"
}

resource "aws_rds_cluster_parameter_group" "aurora_cluster_parameter_group" {
  name        = "aurora-cluster-parameter-group"
  family      = "aurora-mysql5.7"
  description = "aurora-cluster-parameter-group"
}

