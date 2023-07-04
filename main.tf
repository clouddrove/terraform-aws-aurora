##------------------------------------------------------------------------------
## Labels module callled that will be used for naming and tags.
##------------------------------------------------------------------------------
module "labels" {
  source  = "clouddrove/labels/aws"
  version = "1.3.0"

  name        = var.name
  repository  = var.repository
  environment = var.environment
  managedby   = var.managedby
  label_order = var.label_order
}

locals {
  port            = var.port == "" ? var.engine == "aurora-postgresql" ? "5432" : "3306" : var.port
  master_password = var.password == "" ? random_id.master_password.b64_url : var.password
  is_serverless   = var.engine_mode == "serverless"
}

# Random string to use as master password unless one is specified
resource "random_id" "master_password" {
  byte_length = 20
}

##------------------------------------------------------------------------------
## Provides an RDS DB subnet group resource.
##------------------------------------------------------------------------------
resource "aws_db_subnet_group" "default" {
  count = var.enable == true && var.enabled_subnet_group == true ? 1 : 0

  name        = module.labels.id
  description = format("For Aurora cluster %s", module.labels.id)
  subnet_ids  = var.subnets
  tags        = module.labels.tags
}


##------------------------------------------------------------------------------
## Below resources will create SECURITY-GROUP and its components.
##------------------------------------------------------------------------------
resource "aws_security_group" "default" {
  count = var.enable_security_group && length(var.sg_ids) < 1 ? 1 : 0

  name        = format("%s-sg", module.labels.id)
  vpc_id      = var.vpc_id
  description = var.sg_description
  tags        = module.labels.tags
  lifecycle {
    create_before_destroy = true
  }
}

data "aws_security_group" "existing" {
  count  = var.is_external ? 1 : 0
  id     = var.existing_sg_id
  vpc_id = var.vpc_id
}

##------------------------------------------------------------------------------
## Below resources will create SECURITY-GROUP-RULE and its components.
##------------------------------------------------------------------------------
#tfsec:ignore:aws-ec2-no-public-egress-sgr
resource "aws_security_group_rule" "egress" {
  count = (var.enable_security_group == true && length(var.sg_ids) < 1 && var.is_external == false && var.egress_rule == true) ? 1 : 0

  description       = var.sg_egress_description
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = join("", aws_security_group.default.*.id)
}
#tfsec:ignore:aws-ec2-no-public-egress-sgr
resource "aws_security_group_rule" "egress_ipv6" {
  count = (var.enable_security_group == true && length(var.sg_ids) < 1 && var.is_external == false) && var.egress_rule == true ? 1 : 0

  description       = var.sg_egress_ipv6_description
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = join("", aws_security_group.default.*.id)
}

resource "aws_security_group_rule" "ingress" {
  count = length(var.allowed_ip) > 0 == true && length(var.sg_ids) < 1 ? length(compact(var.allowed_ports)) : 0

  description       = var.sg_ingress_description
  type              = "ingress"
  from_port         = element(var.allowed_ports, count.index)
  to_port           = element(var.allowed_ports, count.index)
  protocol          = var.protocol
  cidr_blocks       = var.allowed_ip
  security_group_id = join("", aws_security_group.default.*.id)
}

##------------------------------------------------------------------------------
## Below resources will create KMS-KEY and its components.
##------------------------------------------------------------------------------
resource "aws_kms_key" "default" {
  count = var.kms_key_enabled && var.kms_key_id == "" ? 1 : 0

  description              = var.kms_description
  key_usage                = var.key_usage
  deletion_window_in_days  = var.deletion_window_in_days
  is_enabled               = var.is_enabled
  enable_key_rotation      = var.enable_key_rotation
  customer_master_key_spec = var.customer_master_key_spec
  policy                   = data.aws_iam_policy_document.default.json
  multi_region             = var.kms_multi_region
  tags                     = module.labels.tags
}

resource "aws_kms_alias" "default" {
  count = var.kms_key_enabled && var.kms_key_id == "" ? 1 : 0

  name          = coalesce(var.alias, format("alias/%v", module.labels.id))
  target_key_id = var.kms_key_id == "" ? join("", aws_kms_key.default.*.id) : var.kms_key_id
}

##------------------------------------------------------------------------------
## Data block called to get Permissions that will be used in creating policy.
##------------------------------------------------------------------------------
data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "aws_iam_policy_document" "default" {
  version = "2012-10-17"
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        format(
          "arn:%s:iam::%s:root",
          join("", data.aws_partition.current.*.partition),
          data.aws_caller_identity.current.account_id
        )
      ]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }
}


##------------------------------------------------------------------------------
## Provides an RDS Cluster Resource. A Cluster Resource defines attributes that are applied to the entire cluster of RDS Cluster Instances.
##------------------------------------------------------------------------------
resource "aws_rds_cluster" "default" {
  count = var.enable == true && var.enabled_rds_cluster == true && var.serverless_enabled == false ? 1 : 0

  cluster_identifier                  = module.labels.id
  engine                              = var.engine
  engine_version                      = var.engine_version
  kms_key_id                          = var.kms_key_id == "" ? join("", aws_kms_key.default.*.arn) : var.kms_key_id
  database_name                       = var.database_name
  master_username                     = var.username
  master_password                     = local.master_password
  backtrack_window                    = var.backtrack_window
  final_snapshot_identifier           = format("%s-%s-%s", var.final_snapshot_identifier_prefix, module.labels.id, random_id.snapshot_identifier.hex)
  skip_final_snapshot                 = var.skip_final_snapshot
  deletion_protection                 = var.deletion_protection
  backup_retention_period             = var.backup_retention_period
  preferred_backup_window             = var.preferred_backup_window
  preferred_maintenance_window        = var.preferred_maintenance_window
  port                                = local.port
  db_subnet_group_name                = join("", aws_db_subnet_group.default.*.name)
  vpc_security_group_ids              = length(var.sg_ids) < 1 ? aws_security_group.default.*.id : var.sg_ids
  snapshot_identifier                 = var.snapshot_identifier
  storage_encrypted                   = var.storage_encrypted
  apply_immediately                   = var.apply_immediately
  copy_tags_to_snapshot               = var.copy_tags_to_snapshot
  enabled_cloudwatch_logs_exports     = var.enabled_cloudwatch_logs_exports
  db_cluster_parameter_group_name     = var.engine == "aurora-postgresql" ? aws_rds_cluster_parameter_group.postgresql.*.id[0] : aws_rds_cluster_parameter_group.aurora.*.id[0]
  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  dynamic "scaling_configuration" {
    for_each = length(keys(var.scaling_configuration)) == 0 ? [] : [var.scaling_configuration]

    content {
      auto_pause               = lookup(scaling_configuration.value, "auto_pause", null)
      max_capacity             = lookup(scaling_configuration.value, "max_capacity", null)
      min_capacity             = lookup(scaling_configuration.value, "min_capacity", null)
      seconds_until_auto_pause = lookup(scaling_configuration.value, "seconds_until_auto_pause", null)
      timeout_action           = lookup(scaling_configuration.value, "timeout_action", null)
    }
  }

  dynamic "s3_import" {
    for_each = var.s3_import != null ? [var.s3_import] : []
    content {
      source_engine         = var.engine
      source_engine_version = lookup(s3_import.value, "source_engine_version", null)
      bucket_name           = lookup(s3_import.value, "bucket_name", null)
      bucket_prefix         = lookup(s3_import.value, "bucket_prefix", null)
      ingestion_role        = lookup(s3_import.value, "ingestion_role", null)
    }
  }

  tags = module.labels.tags
}

##------------------------------------------------------------------------------
## aws_rds_cluster_instance. Provides an RDS Cluster Instance Resource.
##------------------------------------------------------------------------------
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

####----------------------------------------------------------------------------
## The resource random_id generates random numbers that are intended to be used as unique identifiers for other resources.
####----------------------------------------------------------------------------
resource "random_id" "snapshot_identifier" {
  keepers = {
    id = module.labels.id
  }
  byte_length = 4
}

####----------------------------------------------------------------------------
### Provides an RDS DB parameter group resource.
####----------------------------------------------------------------------------
resource "aws_db_parameter_group" "postgresql" {
  count = var.enable == true && var.engine == "aurora-postgresql" && var.serverless_enabled == false ? 1 : 0

  name        = module.labels.id
  family      = var.postgresql_family
  description = format("Parameter group for %s", module.labels.id)
  tags        = module.labels.tags
}

resource "aws_db_parameter_group" "aurora" {
  count = var.enable == true && var.engine == "aurora-mysql" && var.serverless_enabled == false ? 1 : 0

  name        = module.labels.id
  family      = var.mysql_family
  description = format("Parameter group for %s", module.labels.id)
  tags        = module.labels.tags
}

##------------------------------------------------------------------------------
# Provides an RDS DB cluster parameter group resource.
##------------------------------------------------------------------------------
resource "aws_rds_cluster_parameter_group" "postgresql" {
  count = var.enable == true && var.engine == "aurora-postgresql" && var.serverless_enabled == false ? 1 : 0

  name        = format("%s-cluster", module.labels.id)
  family      = var.postgresql_family
  description = format("Cluster parameter group for %s", module.labels.id)
  tags        = module.labels.tags
}

resource "aws_rds_cluster_parameter_group" "aurora" {
  count = var.enable == true && var.engine == "aurora-mysql" && var.serverless_enabled == false ? 1 : 0

  name        = format("%s-cluster", module.labels.id)
  family      = var.mysql_family
  description = format("Cluster parameter group for %s", module.labels.id)
  tags        = module.labels.tags
}

resource "aws_rds_cluster_parameter_group" "postgresql_serverless" {
  count = var.enable && var.engine == "aurora-postgresql" ? 1 : 0

  name        = format("%s-serverless-cluster", module.labels.id)
  family      = var.postgresql_family_serverless
  description = format("Cluster parameter group for %s Postgresql Serverless", module.labels.id)
  tags        = module.labels.tags
}

resource "aws_rds_cluster_parameter_group" "aurora_serverless" {
  count = var.enable && var.engine == "aurora" ? 1 : 0

  name        = format("%s-serverless-cluster", module.labels.id)
  family      = var.mysql_family_serverless
  description = format("Cluster parameter group for %s MySQL ", module.labels.id)
  tags        = module.labels.tags
}

##------------------------------------------------------------------------------
## Below resource will create ssm-parameter resource for mysql with endpoint.
##------------------------------------------------------------------------------
resource "aws_ssm_parameter" "secret-endpoint" {
  count = var.enable && var.ssm_parameter_endpoint_enabled ? 1 : 0

  name        = format("/%s/%s/endpoint", var.environment, var.name)
  description = var.ssm_parameter_description
  type        = var.ssm_parameter_type
  value       = join("", aws_rds_cluster.default.*.endpoint)
  key_id      = var.kms_key_id == "" ? join("", aws_kms_key.default.*.arn) : var.kms_key_id
}

##------------------------------------------------------------------------------
# Manages an RDS Aurora Cluster Endpoint.
##------------------------------------------------------------------------------
resource "aws_rds_cluster_endpoint" "this" {
  count = var.enable && local.is_serverless ? 1 : 0

  cluster_endpoint_identifier = "static"
  cluster_identifier          = aws_rds_cluster.default[0].id
  custom_endpoint_type        = "READER"
  excluded_members            = aws_rds_cluster_instance.default.*.id
  tags                        = module.labels.tags
}
