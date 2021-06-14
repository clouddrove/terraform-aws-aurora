#Module      : LABEL
#Description : Terraform label module variables.
variable "name" {
  type        = string
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "repository" {
  type        = string
  default     = ""
  description = "Terraform current module repo"

  validation {
    # regex(...) fails if it cannot find a match
    condition     = can(regex("^https://", var.repository))
    error_message = "The module-repo value must be a valid Git repo link."
  }
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "label_order" {
  type        = list(any)
  default     = []
  description = "Label order, e.g. `name`,`application`."
}

variable "managedby" {
  type        = string
  default     = "hello@clouddrove.com"
  description = "ManagedBy, eg 'CloudDrove'."
}

#Module      : RDS AURORA CLUSTER
#Description : Manages a RDS Aurora Cluster.
variable "subnets" {
  type        = list(string)
  default     = []
  description = "List of subnet IDs to use."
}

variable "replica_count" {
  type        = number
  default     = 1
  description = "Number of reader nodes to create.  If `replica_scale_enable` is `true`, the value of `replica_scale_min` is used instead."
}

variable "identifier_prefix" {
  type        = string
  default     = ""
  description = "Prefix for cluster and instance identifier."
}

variable "instance_type" {
  type        = string
  default     = ""
  description = "Instance type to use."
}

variable "publicly_accessible" {
  type        = bool
  default     = false
  description = "Whether the DB should have a public IP address."
}

variable "database_name" {
  type        = string
  default     = ""
  description = "Name for an automatically created database on cluster creation."
}

variable "username" {
  type        = string
  default     = ""
  description = "Master DB username."
  sensitive   = true
}

variable "password" {
  type        = string
  default     = ""
  description = "Master DB password."
  sensitive   = true
}

variable "final_snapshot_identifier_prefix" {
  type        = string
  default     = "final"
  description = "The prefix name to use when creating a final snapshot on cluster destroy, appends a random 8 digits to name to ensure it's unique too."
}

variable "skip_final_snapshot" {
  type        = bool
  default     = false
  description = "Should a final snapshot be created on cluster destroy."
}

variable "deletion_protection" {
  type        = bool
  default     = true
  description = "If the DB instance should have deletion protection enabled."
}

variable "backup_retention_period" {
  type        = number
  default     = 7
  description = "How long to keep backups for (in days)."
}

variable "preferred_backup_window" {
  type        = string
  default     = "02:00-03:00"
  description = "When to perform DB backups."
}

variable "preferred_maintenance_window" {
  type        = string
  default     = "sun:05:00-sun:06:00"
  description = "When to perform DB maintenance."
}

variable "port" {
  type        = string
  default     = ""
  description = "The port on which to accept connections."
  sensitive   = true
}

variable "apply_immediately" {
  type        = bool
  default     = false
  description = "Determines whether or not any DB modifications are applied immediately, or during the maintenance window."
}

variable "monitoring_interval" {
  type        = number
  default     = 5
  description = "The interval (seconds) between points when Enhanced Monitoring metrics are collected."
}

variable "auto_minor_version_upgrade" {
  type        = bool
  default     = true
  description = "Determines whether minor engine upgrades will be performed automatically in the maintenance window."
}

variable "db_parameter_group_name" {
  type        = string
  default     = "default.aurora5.6"
  description = "The name of a DB parameter group to use."
  sensitive   = true
}

variable "db_cluster_parameter_group_name" {
  type        = string
  default     = "default.aurora5.6"
  description = "The name of a DB Cluster parameter group to use."
  sensitive   = true
}

variable "snapshot_identifier" {
  type        = string
  default     = ""
  description = "DB snapshot to create this database from."
}


variable "kms_key_id" {
  type        = string
  default     = ""
  description = "The ARN for the KMS encryption key if one is set to the cluster."
}

variable "engine" {
  type        = string
  default     = "aurora-mysql"
  description = "Aurora database engine type, currently aurora, aurora-mysql or aurora-postgresql."
}

variable "engine_version" {
  type        = string
  default     = "5.6.10a"
  description = "Aurora database engine version."
}

variable "engine_mode" {
  type        = string
  default     = "serverless"
  description = "The database engine mode."
}

variable "replica_scale_enabled" {
  type        = bool
  default     = false
  description = "Whether to enable autoscaling for RDS Aurora (MySQL) read replicas."
}

variable "replica_scale_max" {
  type        = number
  default     = 0
  description = "Maximum number of replicas to allow scaling."
}

variable "replica_scale_min" {
  type        = number
  default     = 2
  description = "Minimum number of replicas to allow scaling."
}

variable "replica_scale_cpu" {
  type        = number
  default     = 70
  description = "CPU usage to trigger autoscaling."
}

variable "replica_scale_in_cooldown" {
  type        = number
  default     = 300
  description = "Cooldown in seconds before allowing further scaling operations after a scale in."
}

variable "replica_scale_out_cooldown" {
  type        = number
  default     = 300
  description = "Cooldown in seconds before allowing further scaling operations after a scale out."
}

variable "performance_insights_enabled" {
  type        = bool
  default     = false
  description = "Specifies whether Performance Insights is enabled or not."
}

variable "performance_insights_kms_key_id" {
  type        = string
  default     = ""
  description = "The ARN for the KMS key to encrypt Performance Insights data."
}

variable "iam_database_authentication_enabled" {
  type        = bool
  default     = true
  description = "Specifies whether IAM Database authentication should be enabled or not. Not all versions and instances are supported. Refer to the AWS documentation to see which versions are supported."
}

variable "aws_security_group" {
  type        = list(string)
  default     = []
  description = "Specifies whether IAM Database authentication should be enabled or not. Not all versions and instances are supported. Refer to the AWS documentation to see which versions are supported."
}

variable "enabled_cloudwatch_logs_exports" {
  type        = list(string)
  default     = []
  description = "List of log types to export to cloudwatch. If omitted, no logs will be exported. The following log types are supported: audit, error, general, slowquery, postgresql (PostgreSQL)."
}

variable "availability_zone" {
  type        = string
  default     = ""
  description = "The Availability Zone of the RDS instance."
}


variable "enabled_subnet_group" {
  type        = bool
  default     = true
  description = "Set to false to prevent the module from creating any resources."
}

variable "enabled_rds_cluster" {
  type        = bool
  default     = true
  description = "Set to false to prevent the module from creating any resources."
}

variable "postgresql_family" {
  type        = string
  default     = "aurora-postgresql9.6"
  description = "The family of the DB parameter group."
}

variable "mysql_family" {
  type        = string
  default     = "aurora-mysql5.7"
  description = "The family of the DB parameter group."
}

variable "enable" {
  type        = bool
  default     = true
  description = "Set to false to prevent the module from creating any resources."
}

variable "postgresql_family_serverless" {
  type        = string
  default     = "aurora-postgresql10"
  description = "The family of the DB parameter group."
}

variable "mysql_family_serverless" {
  type        = string
  default     = "aurora5.6"
  description = "The family of the DB parameter group."
}

variable "serverless_enabled" {
  type        = bool
  default     = false
  description = "Whether serverless is enabled or not."
}

variable "backtrack_window" {
  type        = number
  default     = 0
  description = "The target backtrack window, in seconds. Only available for aurora engine currently.Must be between 0 and 259200 (72 hours)"
}

variable "replication_source_identifier" {
  type        = string
  default     = ""
  description = "ARN of a source DB cluster or DB instance if this DB cluster is to be created as a Read Replica."
}

variable "iam_roles" {
  type        = list(string)
  default     = []
  description = "A List of ARNs for the IAM roles to associate to the RDS Cluster."
}

variable "source_region" {
  type        = string
  default     = ""
  description = "The source region for an encrypted replica DB cluster."
}

variable "availability_zones" {
  type        = list(any)
  default     = []
  description = "The Availability Zone of the RDS cluster."
}

variable "enable_http_endpoint" {
  type        = bool
  default     = true
  description = "Enable HTTP endpoint (data API). Only valid when engine_mode is set to serverless."
}

variable "auto_pause" {
  type        = bool
  default     = false
  description = "Whether to enable automatic pause. A DB cluster can be paused only when it's idle (it has no connections)."
}

variable "max_capacity" {
  type        = number
  default     = 4
  description = "The maximum capacity. Valid capacity values are 1, 2, 4, 8, 16, 32, 64, 128, and 256."
}

variable "min_capacity" {
  type        = number
  default     = 2
  description = "The minimum capacity. Valid capacity values are 1, 2, 4, 8, 16, 32, 64, 128, and 256."
}

variable "seconds_until_auto_pause" {
  type        = number
  default     = 300
  description = "The time, in seconds, before an Aurora DB cluster in serverless mode is paused. Valid values are 300 through 86400."
}

variable "timeout_action" {
  type        = string
  default     = "RollbackCapacityChange"
  description = "The action to take when the timeout is reached. Valid values: ForceApplyCapacityChange, RollbackCapacityChange."
}

variable "scaling_configuration" {
  description = "Map of nested attributes with scaling properties. Only valid when engine_mode is set to `serverless`"
  type        = map(string)
  default     = {}
}

variable "s3_import" {
  description = "Configuration map used to restore from a Percona Xtrabackup in S3 (only MySQL is supported)"
  type        = map(string)
  default     = null
}
