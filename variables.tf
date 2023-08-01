#Module      : LABEL
#Description : Terraform label module variables.
variable "name" {
  type        = string
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "repository" {
  type        = string
  default     = "https://github.com/clouddrove/terraform-aws-aurora"
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

variable "replica_scale_min" {
  type        = number
  default     = 2
  description = "Minimum number of replicas to allow scaling."
}

variable "performance_insights_enabled" {
  type        = bool
  default     = true
  description = "Specifies whether Performance Insights is enabled or not."
}

variable "iam_database_authentication_enabled" {
  type        = bool
  default     = true
  description = "Specifies whether IAM Database authentication should be enabled or not. Not all versions and instances are supported. Refer to the AWS documentation to see which versions are supported."
}

variable "enabled_cloudwatch_logs_exports" {
  type        = list(string)
  default     = ["audit", "general"]
  description = "List of log types to export to cloudwatch. If omitted, no logs will be exported. The following log types are supported: audit, error, general, slowquery, postgresql (PostgreSQL)."
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
  default     = "aurora-postgresql13"
  description = "The family of the DB parameter group."
}

variable "mysql_family" {
  type        = string
  default     = "aurora-mysql8.0"
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

variable "scaling_configuration" {
  type        = map(string)
  default     = {}
  description = "Map of nested attributes with scaling properties. Only valid when engine_mode is set to `serverless`"
}

variable "s3_import" {
  type        = map(string)
  default     = null
  description = "Configuration map used to restore from a Percona Xtrabackup in S3 (only MySQL is supported)"
}

variable "storage_encrypted" {
  type        = bool
  default     = true
  description = "Specifies whether the underlying storage layer should be encrypted."
}

variable "copy_tags_to_snapshot" {
  type        = bool
  default     = true
  description = "Copy all Cluster tags to snapshots."
}

variable "enable_security_group" {
  type        = bool
  default     = true
  description = "Enable default Security Group with only Egress traffic allowed."
}

variable "sg_ids" {
  type        = list(any)
  default     = []
  description = "of the security group id."
}

variable "vpc_id" {
  type        = string
  default     = ""
  description = "The ID of the VPC that the instance security group belongs to."
  sensitive   = true
}

variable "sg_description" {
  type        = string
  default     = "Instance default security group (only egress access is allowed)."
  description = "The security group description."
}

variable "is_external" {
  type        = bool
  default     = false
  description = "enable to udated existing security Group"
}

variable "egress_rule" {
  type        = bool
  default     = true
  description = "Enable to create egress rule"
}

variable "sg_egress_description" {
  type        = string
  default     = "Description of the rule."
  description = "Description of the egress and ingress rule"
}

variable "sg_egress_ipv6_description" {
  type        = string
  default     = "Description of the rule."
  description = "Description of the egress_ipv6 rule"
}

variable "allowed_ip" {
  type        = list(any)
  default     = []
  description = "List of allowed ip."
}

variable "allowed_ports" {
  type        = list(any)
  default     = []
  description = "List of allowed ingress ports"
}

variable "sg_ingress_description" {
  type        = string
  default     = "Description of the ingress rule use elasticache."
  description = "Description of the ingress rule"
}

variable "protocol" {
  type        = string
  default     = "tcp"
  description = "The protocol. If not icmp, tcp, udp, or all use the."
}

variable "kms_key_enabled" {
  type        = bool
  default     = true
  description = "Specifies whether the kms is enabled or disabled."
}

variable "kms_description" {
  type        = string
  default     = "Parameter Store KMS master key"
  description = "The description of the key as viewed in AWS console."
}

variable "key_usage" {
  type        = string
  default     = "ENCRYPT_DECRYPT"
  sensitive   = true
  description = "Specifies the intended use of the key. Defaults to ENCRYPT_DECRYPT, and only symmetric encryption and decryption are supported."
}

variable "deletion_window_in_days" {
  type        = number
  default     = 7
  description = "Duration in days after which the key is deleted after destruction of the resource."
}

variable "is_enabled" {
  type        = bool
  default     = true
  description = "Specifies whether the key is enabled."
}

variable "enable_key_rotation" {
  type        = string
  default     = true
  description = "Specifies whether key rotation is enabled."
}

variable "customer_master_key_spec" {
  type        = string
  default     = "SYMMETRIC_DEFAULT"
  description = "Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports. Valid values: SYMMETRIC_DEFAULT, RSA_2048, RSA_3072, RSA_4096, ECC_NIST_P256, ECC_NIST_P384, ECC_NIST_P521, or ECC_SECG_P256K1. Defaults to SYMMETRIC_DEFAULT."
  sensitive   = true
}

variable "kms_multi_region" {
  type        = bool
  default     = false
  description = "Indicates whether the KMS key is a multi-Region (true) or regional (false) key."
}

variable "alias" {
  type        = string
  default     = "alias/aurora"
  description = "The display name of the alias. The name must start with the word `alias` followed by a forward slash."
}

variable "ssm_parameter_description" {
  type        = string
  default     = "Description of the parameter."
  description = "SSM Parameters can be imported using."
}

variable "ssm_parameter_type" {
  type        = string
  default     = "SecureString"
  description = "Type of the parameter."
}

variable "ssm_parameter_endpoint_enabled" {
  type        = bool
  default     = false
  description = "Name of the parameter."
}

variable "endpoints" {
  type        = any
  default     = {}
  description = "Map of additional cluster endpoints and their attributes to be created"
}

variable "enabled_monitoring_role" {
  type        = bool
  default     = true
  description = "Create IAM role with a defined name that permits RDS to send enhanced monitoring metrics to CloudWatch Logs."
}

variable "monitoring_role_description" {
  type        = string
  default     = null
  description = "Description of the monitoring IAM role"
}

variable "monitoring_role_permissions_boundary" {
  type        = string
  default     = null
  description = "ARN of the policy that is used to set the permissions boundary for the monitoring IAM role"
}

variable "monitoring_role_name" {
  type        = string
  default     = "rds-monitoring-role"
  description = "Name of the IAM role which will be created when create_monitoring_role is enabled."
}

variable "mysql_iam_role_tags" {
  type        = map(any)
  default     = {}
  description = "Additional tags for the mysql iam role"
}
