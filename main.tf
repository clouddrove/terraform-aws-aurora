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
  extra_tags  = var.extra_tags
}

data "aws_partition" "current" {}
locals {
  create           = var.create
  port             = coalesce(var.port, (var.engine == "aurora-postgresql" || var.engine == "postgres" ? 5432 : 3306))
  backtrack_window = (var.engine == "aurora-mysql" || var.engine == "aurora") && var.engine_mode != "serverless" ? var.backtrack_window : 0
  is_serverless    = var.engine_mode == "serverless"
}

##-----------------------------------------------------------------------------
## Provides an RDS DB subnet group resource.
##-----------------------------------------------------------------------------
resource "aws_db_subnet_group" "default" {
  count = var.enable == true && var.enabled_subnet_group == true ? 1 : 0

  name        = module.labels.id
  description = format("For Aurora cluster %s", module.labels.id)
  subnet_ids  = var.subnets
  tags        = module.labels.tags
}

resource "random_id" "password" {
  count       = var.manage_master_user_password == false ? 1 : 0
  byte_length = 20
}

##-----------------------------------------------------------------------------
## Manages a RDS Aurora Cluster. To manage cluster instances that inherit configuration from the cluster (when not running the cluster in serverless engine mode), see the aws_rds_cluster_instance resource. To manage non-Aurora databases (e.g. MySQL, PostgreSQL, SQL Server, etc.), see the aws_db_instance resource.
##-----------------------------------------------------------------------------
resource "aws_rds_cluster" "this" {
  count                               = local.create ? 1 : 0
  allocated_storage                   = var.allocated_storage
  allow_major_version_upgrade         = var.allow_major_version_upgrade
  apply_immediately                   = var.apply_immediately
  availability_zones                  = var.availability_zones
  backup_retention_period             = var.backup_retention_period
  backtrack_window                    = local.backtrack_window
  cluster_identifier                  = module.labels.id
  cluster_members                     = var.cluster_members
  copy_tags_to_snapshot               = var.copy_tags_to_snapshot
  database_name                       = var.is_primary_cluster ? var.database_name : null
  db_cluster_instance_class           = var.db_cluster_instance_class
  db_cluster_parameter_group_name     = var.create_db_cluster_parameter_group ? aws_rds_cluster_parameter_group.this[0].id : var.db_cluster_parameter_group_name
  db_instance_parameter_group_name    = var.allow_major_version_upgrade ? var.db_cluster_db_instance_parameter_group_name : null
  db_subnet_group_name                = join("", aws_db_subnet_group.default[*].name)
  deletion_protection                 = var.deletion_protection
  enable_global_write_forwarding      = var.enable_global_write_forwarding
  enabled_cloudwatch_logs_exports     = var.enabled_cloudwatch_logs_exports
  enable_http_endpoint                = var.enable_http_endpoint
  engine                              = var.engine
  engine_mode                         = var.engine_mode
  engine_version                      = var.engine_version
  final_snapshot_identifier           = var.final_snapshot_identifier
  global_cluster_identifier           = var.global_cluster_identifier
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  iops                                = var.iops
  kms_key_id                          = var.kms_key_id
  manage_master_user_password         = var.global_cluster_identifier == null && var.manage_master_user_password ? var.manage_master_user_password : null
  master_user_secret_kms_key_id       = var.global_cluster_identifier == null && var.manage_master_user_password ? var.master_user_secret_kms_key_id : null
  master_password                     = var.is_primary_cluster && !var.manage_master_user_password ? random_id.password[0].b64_url : null
  master_username                     = var.is_primary_cluster ? var.master_username : null
  network_type                        = var.network_type
  port                                = local.port
  preferred_backup_window             = local.is_serverless ? null : var.preferred_backup_window
  preferred_maintenance_window        = local.is_serverless ? null : var.preferred_maintenance_window
  replication_source_identifier       = var.replication_source_identifier

  dynamic "restore_to_point_in_time" {
    for_each = length(var.restore_to_point_in_time) > 0 ? [var.restore_to_point_in_time] : []

    content {
      restore_to_time            = try(restore_to_point_in_time.value.restore_to_time, null)
      restore_type               = try(restore_to_point_in_time.value.restore_type, null)
      source_cluster_identifier  = restore_to_point_in_time.value.source_cluster_identifier
      use_latest_restorable_time = try(restore_to_point_in_time.value.use_latest_restorable_time, null)
    }
  }

  dynamic "s3_import" {
    for_each = length(var.s3_import) > 0 && !local.is_serverless ? [var.s3_import] : []

    content {
      bucket_name           = s3_import.value.bucket_name
      bucket_prefix         = try(s3_import.value.bucket_prefix, null)
      ingestion_role        = s3_import.value.ingestion_role
      source_engine         = "mysql"
      source_engine_version = s3_import.value.source_engine_version
    }
  }

  dynamic "scaling_configuration" {
    for_each = length(var.scaling_configuration) > 0 && local.is_serverless ? [var.scaling_configuration] : []

    content {
      auto_pause               = try(scaling_configuration.value.auto_pause, null)
      max_capacity             = try(scaling_configuration.value.max_capacity, null)
      min_capacity             = try(scaling_configuration.value.min_capacity, null)
      seconds_until_auto_pause = try(scaling_configuration.value.seconds_until_auto_pause, null)
      timeout_action           = try(scaling_configuration.value.timeout_action, null)
    }
  }

  dynamic "serverlessv2_scaling_configuration" {
    for_each = length(var.serverlessv2_scaling_configuration) > 0 && var.engine_mode == "provisioned" ? [var.serverlessv2_scaling_configuration] : []

    content {
      max_capacity = serverlessv2_scaling_configuration.value.max_capacity
      min_capacity = serverlessv2_scaling_configuration.value.min_capacity
    }
  }

  skip_final_snapshot    = var.skip_final_snapshot
  snapshot_identifier    = var.snapshot_identifier
  source_region          = var.source_region
  storage_encrypted      = var.storage_encrypted
  storage_type           = var.storage_type
  vpc_security_group_ids = compact(concat([try(aws_security_group.default[0].id, "")], var.sg_ids))

  timeouts {
    create = try(var.cluster_timeouts.create, null)
    update = try(var.cluster_timeouts.update, null)
    delete = try(var.cluster_timeouts.delete, null)
  }

  lifecycle {
    ignore_changes = [
      # See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster#replication_source_identifier
      # Since this is used either in read-replica clusters or global clusters, this should be acceptable to specify
      replication_source_identifier,
      global_cluster_identifier,
      snapshot_identifier,
    ]
  }

  tags = module.labels.tags
}

##-----------------------------------------------------------------------------
## Provides an RDS Cluster Instance Resource. A Cluster Instance Resource defines attributes that are specific to a single instance in a RDS Cluster, specifically running Amazon Aurora.
##-----------------------------------------------------------------------------
resource "aws_rds_cluster_instance" "this" {
  for_each                              = { for k, v in var.instances : k => v if local.create && !local.is_serverless }
  apply_immediately                     = try(each.value.apply_immediately, var.apply_immediately)
  auto_minor_version_upgrade            = try(each.value.auto_minor_version_upgrade, var.auto_minor_version_upgrade)
  availability_zone                     = try(each.value.availability_zone, null)
  ca_cert_identifier                    = var.ca_cert_identifier
  cluster_identifier                    = aws_rds_cluster.this[0].id
  copy_tags_to_snapshot                 = try(each.value.copy_tags_to_snapshot, var.copy_tags_to_snapshot)
  db_parameter_group_name               = var.create_db_parameter_group ? aws_db_parameter_group.this[0].id : var.db_parameter_group_name
  db_subnet_group_name                  = join("", aws_db_subnet_group.default[*].name)
  engine                                = var.engine
  engine_version                        = var.engine_version
  identifier                            = var.instances_use_identifier_prefix ? null : try(each.value.identifier, "${var.name}-${each.key}")
  identifier_prefix                     = var.instances_use_identifier_prefix ? try(each.value.identifier_prefix, "${var.name}-${each.key}-") : null
  instance_class                        = try(each.value.instance_class, var.instance_class)
  monitoring_interval                   = try(each.value.monitoring_interval, var.monitoring_interval)
  monitoring_role_arn                   = var.create_monitoring_role ? try(aws_iam_role.rds_enhanced_monitoring[0].arn, null) : var.monitoring_role_arn
  performance_insights_enabled          = try(each.value.performance_insights_enabled, var.performance_insights_enabled)
  performance_insights_kms_key_id       = try(each.value.performance_insights_kms_key_id, var.performance_insights_kms_key_id)
  performance_insights_retention_period = try(each.value.performance_insights_retention_period, var.performance_insights_retention_period)
  # preferred_backup_window - is set at the cluster level and will error if provided here
  preferred_maintenance_window = try(each.value.preferred_maintenance_window, var.preferred_maintenance_window)
  promotion_tier               = try(each.value.promotion_tier, null)
  publicly_accessible          = try(each.value.publicly_accessible, var.publicly_accessible)
  tags                         = merge(var.tags, var.cluster_tags)
  timeouts {
    create = try(var.instance_timeouts.create, null)
    update = try(var.instance_timeouts.update, null)
    delete = try(var.instance_timeouts.delete, null)
  }
}

##-----------------------------------------------------------------------------
## Manages an RDS Aurora Cluster Endpoint. You can refer to the User Guide.
##-----------------------------------------------------------------------------
resource "aws_rds_cluster_endpoint" "this" {
  for_each = { for k, v in var.endpoints : k => v if local.create && !local.is_serverless }

  cluster_endpoint_identifier = each.value.identifier
  cluster_identifier          = aws_rds_cluster.this[0].id
  custom_endpoint_type        = each.value.type
  excluded_members            = try(each.value.excluded_members, null)
  static_members              = try(each.value.static_members, null)
  tags                        = merge(var.tags, var.cluster_tags)
  depends_on = [
    aws_rds_cluster_instance.this
  ]
}

##-----------------------------------------------------------------------------
## Manages an RDS DB Instance association with an IAM Role. Example use cases.
##-----------------------------------------------------------------------------
resource "aws_rds_cluster_role_association" "this" {
  for_each = { for k, v in var.iam_roles : k => v if local.create }

  db_cluster_identifier = aws_rds_cluster.this[0].id
  feature_name          = each.value.feature_name
  role_arn              = each.value.role_arn
}

locals {
  create_monitoring_role = local.create && var.create_monitoring_role && var.monitoring_interval > 0
}

data "aws_iam_policy_document" "monitoring_rds_assume_role" {
  count = local.create_monitoring_role ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.${data.aws_partition.current.dns_suffix}"]
    }
  }
}

##-----------------------------------------------------------------------------
## This data source can be used to fetch information about a specific IAM role. By using this data source, you can reference IAM role properties without having to hard code ARNs as input.
##-----------------------------------------------------------------------------
resource "aws_iam_role" "rds_enhanced_monitoring" {
  count       = local.create_monitoring_role ? 1 : 0
  name        = module.labels.id
  description = var.iam_role_description
  path        = var.iam_role_path

  assume_role_policy    = data.aws_iam_policy_document.monitoring_rds_assume_role[0].json
  managed_policy_arns   = var.iam_role_managed_policy_arns
  permissions_boundary  = var.iam_role_permissions_boundary
  force_detach_policies = var.iam_role_force_detach_policies
  max_session_duration  = var.iam_role_max_session_duration

  tags = merge(
    {
      "Name" = format("%s", var.monitoring_role_name)
    },
    module.labels.tags,
    var.mysql_iam_role_tags
  )
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  count = local.create_monitoring_role ? 1 : 0

  role       = aws_iam_role.rds_enhanced_monitoring[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

##-----------------------------------------------------------------------------
## Provides an AutoScaling Group resource.
##-----------------------------------------------------------------------------
resource "aws_appautoscaling_target" "this" {
  count = local.create && var.autoscaling_enabled && !local.is_serverless ? 1 : 0

  max_capacity       = var.autoscaling_max_capacity
  min_capacity       = var.autoscaling_min_capacity
  resource_id        = "cluster:${aws_rds_cluster.this[0].cluster_identifier}"
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  service_namespace  = "rds"

  tags = module.labels.tags
}

##-----------------------------------------------------------------------------
## Provides an Application AutoScaling Policy resource.
##-----------------------------------------------------------------------------
resource "aws_appautoscaling_policy" "this" {
  count = local.create && var.autoscaling_enabled && !local.is_serverless ? 1 : 0

  name               = var.autoscaling_policy_name
  policy_type        = "TargetTrackingScaling"
  resource_id        = "cluster:${aws_rds_cluster.this[0].cluster_identifier}"
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  service_namespace  = "rds"
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = var.predefined_metric_type
    }

    scale_in_cooldown  = var.autoscaling_scale_in_cooldown
    scale_out_cooldown = var.autoscaling_scale_out_cooldown
    target_value       = var.predefined_metric_type == "RDSReaderAverageCPUUtilization" ? var.autoscaling_target_cpu : var.autoscaling_target_connections
  }

  depends_on = [
    aws_appautoscaling_target.this
  ]
}

##-----------------------------------------------------------------------------
## Provides a security group resource.
##-----------------------------------------------------------------------------
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

##-----------------------------------------------------------------------------
## Provides a security group resource.
##-----------------------------------------------------------------------------
#tfsec:ignore:aws-ec2-no-public-egress-sgr
resource "aws_security_group_rule" "egress" {
  count = (var.enable_security_group == true && length(var.sg_ids) < 1 && var.egress_rule == true) ? 1 : 0

  description       = var.sg_egress_description
  type              = "egress"
  from_port         = var.from_port
  to_port           = var.to_port
  protocol          = var.egress_protocol
  cidr_blocks       = var.cidr_blocks
  security_group_id = length(var.sg_ids) > 0 ? var.sg_ids[count.index].id : aws_security_group.default[0].id
}
#tfsec:ignore:aws-ec2-no-public-egress-sgr
resource "aws_security_group_rule" "egress_ipv6" {
  count = (var.enable_security_group == true && length(var.sg_ids) < 1) && var.egress_rule == true ? 1 : 0

  description       = var.sg_egress_ipv6_description
  type              = "egress"
  from_port         = var.from_port
  to_port           = var.to_port
  protocol          = var.egress_protocol
  ipv6_cidr_blocks  = var.ipv6_cidr_blocks
  security_group_id = length(var.sg_ids) > 0 ? var.sg_ids[count.index].id : aws_security_group.default[0].id
}

resource "aws_security_group_rule" "ingress" {
  count = length(var.allowed_ip) > 0 == true && length(var.sg_ids) < 1 ? length(compact(var.allowed_ports)) : 0

  description       = var.sg_ingress_description
  type              = "ingress"
  from_port         = element(var.allowed_ports, count.index)
  to_port           = element(var.allowed_ports, count.index)
  protocol          = var.protocol
  cidr_blocks       = var.allowed_ip
  security_group_id = length(var.sg_ids) > 0 ? var.sg_ids[count.index].id : aws_security_group.default[0].id
}

##-----------------------------------------------------------------------------
## Provides an RDS DB cluster parameter group resource. Documentation of the available parameters for various Aurora engines can be found at:
##-----------------------------------------------------------------------------
resource "aws_rds_cluster_parameter_group" "this" {
  count = local.create && var.create_db_cluster_parameter_group ? 1 : 0

  name        = module.labels.id
  description = var.db_cluster_parameter_group_description
  family      = var.db_cluster_parameter_group_family

  dynamic "parameter" {
    for_each = var.db_cluster_parameter_group_parameters

    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = try(parameter.value.apply_method, "immediate")
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = module.labels.tags
}

##-----------------------------------------------------------------------------
## Provides an RDS DB parameter group resource .Documentation of the available parameters for various RDS engines can be found at.
##-----------------------------------------------------------------------------
resource "aws_db_parameter_group" "this" {
  count = local.create && var.create_db_parameter_group ? 1 : 0

  name        = module.labels.id
  description = var.db_parameter_group_description
  family      = var.db_parameter_group_family

  dynamic "parameter" {
    for_each = var.db_parameter_group_parameters

    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = try(parameter.value.apply_method, "immediate")
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = module.labels.tags
}

##-----------------------------------------------------------------------------------------
## RDS PROXY
##-----------------------------------------------------------------------------------------
data "aws_region" "current" {}

resource "aws_db_proxy" "proxy" {
  count = local.create && var.create_db_proxy ? 1 : 0

  name                   = module.labels.id
  debug_logging          = var.debug_logging
  engine_family          = var.engine_family
  idle_client_timeout    = var.idle_client_timeout
  require_tls            = var.require_tls
  role_arn               = local.create && var.enable_default_proxy_iam_role ? join("", aws_iam_role.proxy_iam_role[*].arn) : var.proxy_role_arn
  vpc_security_group_ids = var.proxy_sg_ids
  vpc_subnet_ids         = var.proxy_subnet_ids

  dynamic "auth" {
    for_each = var.auth
    content {
      auth_scheme               = try(auth.value.auth_scheme, "SECRETS")
      client_password_auth_type = try(auth.value.client_password_auth_type, null)
      description               = try(auth.value.description, null)
      iam_auth                  = try(auth.value.iam_auth, null)
      secret_arn                = try(auth.value.secret_arn, null)
      username                  = try(auth.value.username, null)
    }
  }
  tags = module.labels.tags
}

resource "aws_db_proxy_default_target_group" "proxy" {
  count = local.create && var.create_db_proxy ? 1 : 0

  db_proxy_name = join("", aws_db_proxy.proxy[*].name)

  connection_pool_config {
    connection_borrow_timeout    = var.connection_borrow_timeout
    init_query                   = var.init_query
    max_connections_percent      = var.max_connections_percent
    max_idle_connections_percent = var.max_idle_connections_percent
    session_pinning_filters      = var.session_pinning_filters
  }
}

resource "aws_db_proxy_target" "proxy" {
  count = local.create && var.create_db_proxy ? 1 : 0

  db_proxy_name         = aws_db_proxy.proxy[0].name
  target_group_name     = aws_db_proxy_default_target_group.proxy[0].name
  db_cluster_identifier = aws_rds_cluster.this[0].id
}

resource "aws_db_proxy_endpoint" "proxy" {
  for_each = { for k, v in var.proxy_endpoints : k => v if local.create && var.create_db_proxy }

  db_proxy_name          = aws_db_proxy.proxy[0].name
  db_proxy_endpoint_name = each.value.name
  vpc_subnet_ids         = each.value.vpc_subnet_ids
  vpc_security_group_ids = lookup(each.value, "vpc_security_group_ids", null)
  target_role            = lookup(each.value, "target_role", null)

  tags = module.labels.tags
}

################################################################################
# IAM Role
################################################################################

data "aws_iam_policy_document" "proxy_assume_role" {
  count = local.create && var.create_db_proxy && var.enable_default_proxy_iam_role ? 1 : 0

  statement {
    sid     = "RDSAssume"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["rds.${data.aws_partition.current.dns_suffix}"]
    }
  }
}

resource "aws_iam_role" "proxy_iam_role" {
  count = local.create && var.create_db_proxy && var.enable_default_proxy_iam_role ? 1 : 0

  name        = module.labels.id
  description = var.proxy_iam_role_description
  path        = var.proxy_iam_role_path

  assume_role_policy    = data.aws_iam_policy_document.proxy_assume_role[0].json
  force_detach_policies = var.iam_role_force_detach_policies
  max_session_duration  = var.iam_role_max_session_duration
  permissions_boundary  = var.iam_role_permissions_boundary

  tags = module.labels.tags
}

data "aws_iam_policy_document" "proxy_iam_policy_permissions" {
  count = local.create && var.create_db_proxy && var.enable_default_proxy_iam_role ? 1 : 0

  statement {
    sid       = "DecryptSecrets"
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = ["arn:${data.aws_partition.current.partition}:kms:*:*:key/*"]

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values = [
        "secretsmanager.${data.aws_region.current.region}.${data.aws_partition.current.dns_suffix}"
      ]
    }
  }

  statement {
    sid    = "ListSecrets"
    effect = "Allow"
    actions = [
      "secretsmanager:GetRandomPassword",
      "secretsmanager:ListSecrets",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "GetSecrets"
    effect = "Allow"
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds",
    ]

    resources = distinct([for auth in var.auth : auth.secret_arn])
  }
}

resource "aws_iam_role_policy" "proxy_iam_policy" {
  count = local.create && var.create_db_proxy && var.enable_default_proxy_iam_role ? 1 : 0

  name   = module.labels.id
  policy = data.aws_iam_policy_document.proxy_iam_policy_permissions[0].json
  role   = aws_iam_role.proxy_iam_role[0].id
}
