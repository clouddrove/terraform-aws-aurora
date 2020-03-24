#Module      : LABEL
#Description : Terraform label module variables.
variable "name" {
  type        = string
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "application" {
  type        = string
  default     = ""
  description = "Application (e.g. `cd` or `clouddrove`)."
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "label_order" {
  type        = list
  default     = []
  description = "Label order, e.g. `name`,`application`."
}

variable "managedby" {
  type        = string
  default     = "anmol@clouddrove.com"
  description = "ManagedBy, eg 'CloudDrove' or 'AnmolNagpal'."
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
  description = "Master DB username."
}

variable "password" {
  type        = string
  default     = ""
  description = "Master DB password."
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
  default     = false
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
}

variable "apply_immediately" {
  type        = bool
  default     = false
  description = "Determines whether or not any DB modifications are applied immediately, or during the maintenance window."
}

variable "monitoring_interval" {
  type        = number
  default     = 0
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
}

variable "db_cluster_parameter_group_name" {
  type        = string
  default     = "default.aurora5.6"
  description = "The name of a DB Cluster parameter group to use."
}

variable "snapshot_identifier" {
  type        = string
  default     = ""
  description = "DB snapshot to create this database from."
}

variable "storage_encrypted" {
  type        = bool
  default     = true
  description = "Specifies whether the underlying storage layer should be encrypted."
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
  default     = false
  description = "Specifies whether IAM Database authentication should be enabled or not. Not all versions and instances are supported. Refer to the AWS documentation to see which versions are supported."
}

variable "aws_security_group" {
  type        = list(string)
  default     = []
  description = "Specifies whether IAM Database authentication should be enabled or not. Not all versions and instances are supported. Refer to the AWS documentation to see which versions are supported."
}

variable "availability_zone" {
  type        = string
  default     = ""
  description = "The Availability Zone of the RDS instance."
}

variable "copy_tags_to_snapshot" {
  default     = false
  description = "On delete, copy all Instance tags to the final snapshot (if final_snapshot_identifier is specified)."
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