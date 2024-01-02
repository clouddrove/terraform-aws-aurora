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
  default     = ["name", "environment"]
  description = "Label order, e.g. `name`,`application`."
}

variable "managedby" {
  type        = string
  default     = "hello@clouddrove.com"
  description = "ManagedBy, eg 'CloudDrove'."
}

variable "create" {
  description = "Whether cluster should be created (affects nearly all resources)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

################################################################################
# DB Subnet Group
################################################################################

variable "subnets" {
  description = "List of subnet IDs used by database subnet group created"
  type        = list(string)
  default     = []
}

################################################################################
# Cluster
################################################################################

variable "is_primary_cluster" {
  description = "Determines whether cluster is primary cluster with writer instance (set to `false` for global cluster and replica clusters)"
  type        = bool
  default     = true
}

variable "allocated_storage" {
  description = "The amount of storage in gibibytes (GiB) to allocate to each DB instance in the Multi-AZ DB cluster. (This setting is required to create a Multi-AZ DB cluster)"
  type        = number
  default     = null
}

variable "enable" {
  type        = bool
  default     = true
  description = "Set to false to prevent the module from creating any resources."
}

variable "enabled_subnet_group" {
  type        = bool
  default     = true
  description = "Set to false to prevent the module from creating any resources."
}

variable "allow_major_version_upgrade" {
  description = "Enable to allow major engine version upgrades when changing engine versions. Defaults to `false`"
  type        = bool
  default     = false
}

variable "apply_immediately" {
  description = "Specifies whether any cluster modifications are applied immediately, or during the next maintenance window. Default is `false`"
  type        = bool
  default     = null
}

variable "availability_zones" {
  description = "List of EC2 Availability Zones for the DB cluster storage where DB cluster instances can be created. RDS automatically assigns 3 AZs if less than 3 AZs are configured, which will show as a difference requiring resource recreation next Terraform apply"
  type        = list(string)
  default     = null
}

variable "backup_retention_period" {
  description = "The days to retain backups for. Default `7`"
  type        = number
  default     = 7
}

variable "backtrack_window" {
  description = "The target backtrack window, in seconds. Only available for `aurora` engine currently. To disable backtracking, set this value to 0. Must be between 0 and 259200 (72 hours)"
  type        = number
  default     = null
}

variable "cluster_members" {
  description = "List of RDS Instances that are a part of this cluster"
  type        = list(string)
  default     = null
}

variable "copy_tags_to_snapshot" {
  description = "Copy all Cluster `tags` to snapshots"
  type        = bool
  default     = null
}

variable "database_name" {
  description = "Name for an automatically created database on cluster creation"
  type        = string
  default     = ""
}

variable "db_cluster_instance_class" {
  description = "The compute and memory capacity of each DB instance in the Multi-AZ DB cluster, for example db.m6g.xlarge. Not all DB instance classes are available in all AWS Regions, or for all database engines"
  type        = string
  default     = null
}

variable "db_cluster_db_instance_parameter_group_name" {
  description = "Instance parameter group to associate with all instances of the DB cluster. The `db_cluster_db_instance_parameter_group_name` is only valid in combination with `allow_major_version_upgrade`"
  type        = string
  default     = null
}

variable "deletion_protection" {
  description = "If the DB instance should have deletion protection enabled. The database can't be deleted when this value is set to `true`. The default is `false`"
  type        = bool
  default     = null
}

variable "sg_ingress_description" {
  type        = string
  default     = "Description of the ingress rule use elasticache."
  description = "Description of the ingress rule"
}

variable "allowed_ip" {
  type        = list(any)
  default     = []
  description = "List of allowed ip."
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

variable "allowed_ports" {
  type        = list(any)
  default     = []
  description = "List of allowed ingress ports"
}


variable "protocol" {
  type        = string
  default     = "tcp"
  description = "The protocol. If not icmp, tcp, udp, or all use the."
}
variable "enable_global_write_forwarding" {
  description = "Whether cluster should forward writes to an associated global cluster. Applied to secondary clusters to enable them to forward writes to an `aws_rds_global_cluster`'s primary cluster"
  type        = bool
  default     = null
}

variable "enabled_cloudwatch_logs_exports" {
  description = "Set of log types to export to cloudwatch. If omitted, no logs will be exported. The following log types are supported: `audit`, `error`, `general`, `slowquery`, `postgresql`"
  type        = list(string)
  default     = []
}

variable "enable_http_endpoint" {
  description = "Enable HTTP endpoint (data API). Only valid when engine_mode is set to `serverless`"
  type        = bool
  default     = null
}

variable "engine" {
  description = "The name of the database engine to be used for this DB cluster. Defaults to `aurora`. Valid Values: `aurora`, `aurora-mysql`, `aurora-postgresql`"
  type        = string
  default     = null
}

variable "engine_mode" {
  description = "The database engine mode. Valid values: `global`, `multimaster`, `parallelquery`, `provisioned`, `serverless`. Defaults to: `provisioned`"
  type        = string
  default     = "provisioned"
}

variable "engine_version" {
  description = "The database engine version. Updating this argument results in an outage"
  type        = string
  default     = null
}

variable "final_snapshot_identifier" {
  description = "The name of your final DB snapshot when this DB cluster is deleted. If omitted, no final snapshot will be made"
  type        = string
  default     = null
}

variable "global_cluster_identifier" {
  description = "The global cluster identifier specified on `aws_rds_global_cluster`"
  type        = string
  default     = null
}

variable "iam_database_authentication_enabled" {
  description = "Specifies whether or mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled"
  type        = bool
  default     = null
}

variable "iops" {
  description = "The amount of Provisioned IOPS (input/output operations per second) to be initially allocated for each DB instance in the Multi-AZ DB cluster"
  type        = number
  default     = null
}

variable "kms_key_id" {
  description = "The ARN for the KMS encryption key. When specifying `kms_key_id`, `storage_encrypted` needs to be set to `true`"
  type        = string
  default     = null
}

variable "manage_master_user_password" {
  description = "Set to true to allow RDS to manage the master user password in Secrets Manager. Cannot be set if `master_password` is provided"
  type        = bool
  default     = true
}

variable "master_user_secret_kms_key_id" {
  description = "The Amazon Web Services KMS key identifier is the key ARN, key ID, alias ARN, or alias name for the KMS key"
  type        = string
  default     = null
}

variable "master_username" {
  description = "Username for the master DB user. Required unless `snapshot_identifier` or `replication_source_identifier` is provided or unless a `global_cluster_identifier` is provided when the cluster is the secondary cluster of a global database"
  type        = string
  default     = null
}

variable "network_type" {
  description = "The type of network stack to use (IPV4 or DUAL)"
  type        = string
  default     = null
}

variable "port" {
  description = "The port on which the DB accepts connections"
  type        = string
  default     = null
}

variable "preferred_backup_window" {
  description = "The daily time range during which automated backups are created if automated backups are enabled using the `backup_retention_period` parameter. Time in UTC"
  type        = string
  default     = "02:00-03:00"
}

variable "preferred_maintenance_window" {
  description = "The weekly time range during which system maintenance can occur, in (UTC)"
  type        = string
  default     = "sun:05:00-sun:06:00"
}

variable "replication_source_identifier" {
  description = "ARN of a source DB cluster or DB instance if this DB cluster is to be created as a Read Replica"
  type        = string
  default     = null
}

variable "restore_to_point_in_time" {
  description = "Map of nested attributes for cloning Aurora cluster"
  type        = map(string)
  default     = {}
}

variable "s3_import" {
  description = "Configuration map used to restore from a Percona Xtrabackup in S3 (only MySQL is supported)"
  type        = map(string)
  default     = {}
}

variable "scaling_configuration" {
  description = "Map of nested attributes with scaling properties. Only valid when `engine_mode` is set to `serverless`"
  type        = map(string)
  default     = {}
}

variable "serverlessv2_scaling_configuration" {
  description = "Map of nested attributes with serverless v2 scaling properties. Only valid when `engine_mode` is set to `provisioned`"
  type        = map(string)
  default     = {}
}

variable "skip_final_snapshot" {
  description = "Determines whether a final snapshot is created before the cluster is deleted. If true is specified, no snapshot is created"
  type        = bool
  default     = false
}

variable "snapshot_identifier" {
  description = "Specifies whether or not to create this cluster from a snapshot. You can use either the name or ARN when specifying a DB cluster snapshot, or the ARN when specifying a DB snapshot"
  type        = string
  default     = null
}

variable "source_region" {
  description = "The source region for an encrypted replica DB cluster"
  type        = string
  default     = null
}

variable "storage_encrypted" {
  description = "Specifies whether the DB cluster is encrypted. The default is `true`"
  type        = bool
  default     = true
}

variable "storage_type" {
  description = "Specifies the storage type to be associated with the DB cluster. (This setting is required to create a Multi-AZ DB cluster). Valid values: `io1`, Default: `io1`"
  type        = string
  default     = null
}

variable "cluster_tags" {
  description = "A map of tags to add to only the cluster. Used for AWS Instance Scheduler tagging"
  type        = map(string)
  default     = {}
}

variable "vpc_security_group_ids" {
  description = "List of VPC security groups to associate to the cluster in addition to the security group created"
  type        = list(string)
  default     = []
}

variable "cluster_timeouts" {
  description = "Create, update, and delete timeout configurations for the cluster"
  type        = map(string)
  default     = {}
}

################################################################################
# Cluster Instance(s)
################################################################################

variable "instances" {
  description = "Map of cluster instances and any specific/overriding attributes to be created"
  type        = any
  default     = {}
}

variable "auto_minor_version_upgrade" {
  description = "Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window. Default `true`"
  type        = bool
  default     = null
}

variable "ca_cert_identifier" {
  description = "The identifier of the CA certificate for the DB instance"
  type        = string
  default     = null
}

variable "db_parameter_group_name" {
  description = "The name of the DB parameter group"
  type        = string
  default     = null
}

variable "instances_use_identifier_prefix" {
  description = "Determines whether cluster instance identifiers are used as prefixes"
  type        = bool
  default     = false
}

variable "instance_class" {
  description = "Instance type to use at master instance. Note: if `autoscaling_enabled` is `true`, this will be the same instance class used on instances created by autoscaling"
  type        = string
  default     = ""
}

variable "monitoring_interval" {
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected for instances. Set to `0` to disable. Default is `0`"
  type        = number
  default     = 0
}

variable "performance_insights_enabled" {
  description = "Specifies whether Performance Insights is enabled or not"
  type        = bool
  default     = null
}

variable "performance_insights_kms_key_id" {
  description = "The ARN for the KMS key to encrypt Performance Insights data"
  type        = string
  default     = null
}

variable "performance_insights_retention_period" {
  description = "Amount of time in days to retain Performance Insights data. Either 7 (7 days) or 731 (2 years)"
  type        = number
  default     = null
}

variable "publicly_accessible" {
  description = "Determines whether instances are publicly accessible. Default `false`"
  type        = bool
  default     = false
}

variable "instance_timeouts" {
  description = "Create, update, and delete timeout configurations for the cluster instance(s)"
  type        = map(string)
  default     = {}
}

################################################################################
# Cluster Endpoint(s)
################################################################################

variable "endpoints" {
  description = "Map of additional cluster endpoints and their attributes to be created"
  type        = any
  default     = {}
}

################################################################################
# Cluster IAM Roles
################################################################################

variable "iam_roles" {
  description = "Map of IAM roles and supported feature names to associate with the cluster"
  type        = map(map(string))
  default     = {}
}

################################################################################
# Enhanced Monitoring
################################################################################

variable "create_monitoring_role" {
  description = "Determines whether to create the IAM role for RDS enhanced monitoring"
  type        = bool
  default     = true
}

variable "monitoring_role_arn" {
  description = "IAM role used by RDS to send enhanced monitoring metrics to CloudWatch"
  type        = string
  default     = ""
}

variable "sg_description" {
  type        = string
  default     = "Instance default security group (only egress access is allowed)."
  description = "The security group description."
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


variable "iam_role_description" {
  description = "Description of the monitoring role"
  type        = string
  default     = null
}

variable "iam_role_path" {
  description = "Path for the monitoring role"
  type        = string
  default     = null
}

variable "iam_role_managed_policy_arns" {
  description = "Set of exclusive IAM managed policy ARNs to attach to the monitoring role"
  type        = list(string)
  default     = null
}

variable "iam_role_permissions_boundary" {
  description = "The ARN of the policy that is used to set the permissions boundary for the monitoring role"
  type        = string
  default     = null
}

variable "iam_role_force_detach_policies" {
  description = "Whether to force detaching any policies the monitoring role has before destroying it"
  type        = bool
  default     = null
}

variable "iam_role_max_session_duration" {
  description = "Maximum session duration (in seconds) that you want to set for the monitoring role"
  type        = number
  default     = null
}

################################################################################
# Autoscaling
################################################################################

variable "autoscaling_enabled" {
  description = "Determines whether autoscaling of the cluster read replicas is enabled"
  type        = bool
  default     = false
}

variable "autoscaling_max_capacity" {
  description = "Maximum number of read replicas permitted when autoscaling is enabled"
  type        = number
  default     = 2
}

variable "autoscaling_min_capacity" {
  description = "Minimum number of read replicas permitted when autoscaling is enabled"
  type        = number
  default     = 0
}

variable "autoscaling_policy_name" {
  description = "Autoscaling policy name"
  type        = string
  default     = "target-metric"
}

variable "predefined_metric_type" {
  description = "The metric type to scale on. Valid values are `RDSReaderAverageCPUUtilization` and `RDSReaderAverageDatabaseConnections`"
  type        = string
  default     = "RDSReaderAverageCPUUtilization"
}

variable "autoscaling_scale_in_cooldown" {
  description = "Cooldown in seconds before allowing further scaling operations after a scale in"
  type        = number
  default     = 300
}

variable "autoscaling_scale_out_cooldown" {
  description = "Cooldown in seconds before allowing further scaling operations after a scale out"
  type        = number
  default     = 300
}

variable "autoscaling_target_cpu" {
  description = "CPU threshold which will initiate autoscaling"
  type        = number
  default     = 70
}

variable "autoscaling_target_connections" {
  description = "Average number of connections threshold which will initiate autoscaling. Default value is 70% of db.r4/r5/r6g.large's default max_connections"
  type        = number
  default     = 700
}

################################################################################
# Security Group
################################################################################

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

variable "egress_rule" {
  type        = bool
  default     = true
  description = "Enable to create egress rule"
}
variable "ipv6_cidr_blocks" {
  type        = list(string)
  default     = ["::/0"]
  description = "Enable to create egress rule"
}

variable "vpc_id" {
  description = "ID of the VPC where to create security group"
  type        = string
  default     = ""
}

variable "from_port" {
  description = " (Required) Start port (or ICMP type number if protocol is icmp or icmpv6)."
  type        = number
  default     = 0
}

variable "to_port" {
  description = "equal to 0. The supported values are defined in the IpProtocol argument on the IpPermission API reference"
  type        = number
  default     = 65535
}

variable "egress_protocol" {
  description = "equal to 0. The supported values are defined in the IpProtocol argument on the IpPermission API reference"
  type        = number
  default     = -1
}
variable "cidr_blocks" {
  description = "equal to 0. The supported values are defined in the IpProtocol argument on the IpPermission API reference"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

################################################################################
# Cluster Parameter Group
################################################################################

variable "create_db_cluster_parameter_group" {
  description = "Determines whether a cluster parameter should be created or use existing"
  type        = bool
  default     = false
}

variable "db_cluster_parameter_group_name" {
  description = "The name of the DB cluster parameter group"
  type        = string
  default     = null
}

variable "db_cluster_parameter_group_description" {
  description = "The description of the DB cluster parameter group. Defaults to \"Managed by Terraform\""
  type        = string
  default     = null
}

variable "db_cluster_parameter_group_family" {
  description = "The family of the DB cluster parameter group"
  type        = string
  default     = ""
}

variable "db_cluster_parameter_group_parameters" {
  description = "A list of DB cluster parameters to apply. Note that parameters may differ from a family to an other"
  type        = list(map(string))
  default     = []
}

################################################################################
# DB Parameter Group
################################################################################

variable "create_db_parameter_group" {
  description = "Determines whether a DB parameter should be created or use existing"
  type        = bool
  default     = false
}

variable "db_parameter_group_description" {
  description = "The description of the DB parameter group. Defaults to \"Managed by Terraform\""
  type        = string
  default     = null
}

variable "db_parameter_group_family" {
  description = "The family of the DB parameter group"
  type        = string
  default     = ""
}

variable "db_parameter_group_parameters" {
  description = "A list of DB parameters to apply. Note that parameters may differ from a family to an other"
  type        = list(map(string))
  default     = []
}


##--------------------------------------------------------------------------------------
## RDS PROXY
##--------------------------------------------------------------------------------------
variable "create_db_proxy" {
  type        = bool
  default     = false
  description = "(Optional) Set this to true to create RDS Proxy."
}

variable "auth" {
  type        = any
  default     = {}
  description = ""
}

variable "debug_logging" {
  type        = bool
  default     = false
  description = "(Optional) Whether the proxy includes detailed information about SQL statements in its logs. This information helps you to debug issues involving SQL behavior or the performance and scalability of the proxy connections. The debug information includes the text of SQL statements that you submit through the proxy. Thus, only enable this setting when needed for debugging, and only when you have security measures in place to safeguard any sensitive information that appears in the logs."
}

variable "engine_family" {
  type        = string
  default     = "POSTGRESQL"
  description = "(Required, Forces new resource) The kinds of databases that the proxy can connect to. This value determines which database network protocol the proxy recognizes when it interprets network traffic to and from the database. For Aurora MySQL, RDS for MariaDB, and RDS for MySQL databases, specify MYSQL. For Aurora PostgreSQL and RDS for PostgreSQL databases, specify POSTGRESQL. For RDS for Microsoft SQL Server, specify SQLSERVER. Valid values are MYSQL, POSTGRESQL, and SQLSERVER."
}

variable "idle_client_timeout" {
  type        = number
  default     = 1800
  description = "(Optional) The number of seconds that a connection to the proxy can be inactive before the proxy disconnects it. You can set this value higher or lower than the connection timeout limit for the associated database."
}

variable "require_tls" {
  type        = bool
  default     = false
  description = "(Optional) A Boolean parameter that specifies whether Transport Layer Security (TLS) encryption is required for connections to the proxy. By enabling this setting, you can enforce encrypted TLS connections to the proxy."
}

variable "proxy_sg_ids" {
  type        = list(string)
  default     = []
  description = "(Optional) One or more VPC security group IDs to associate with the new proxy."
}

variable "proxy_subnet_ids" {
  type        = list(string)
  default     = []
  description = "(Required) One or more VPC subnet IDs to associate with the new proxy."
}

variable "enable_default_proxy_iam_role" {
  type        = bool
  default     = true
  description = "(OPTIONAL) Set this to false to pass your own IAM Role for RDS Proxy."
}

variable "proxy_role_arn" {
  type        = string
  default     = ""
  description = "(OPTIONAL) ARN of RDS proxy IAM Role. Can only be set when `enable_default_proxy_iam_role` is set to `false`."
}

variable "connection_borrow_timeout" {
  type        = number
  default     = null
  description = "(Optional) The number of seconds for a proxy to wait for a connection to become available in the connection pool. Only applies when the proxy has opened its maximum number of connections and all connections are busy with client sessions."
}

variable "init_query" {
  type        = string
  default     = ""
  description = "(Optional) One or more SQL statements for the proxy to run when opening each new database connection. Typically used with SET statements to make sure that each connection has identical settings such as time zone and character set. This setting is empty by default. For multiple statements, use semicolons as the separator. You can also include multiple variables in a single SET statement, such as SET x=1, y=2."
}

variable "max_connections_percent" {
  type        = number
  default     = 100
  description = "(Optional) The maximum size of the connection pool for each target in a target group. For Aurora MySQL, it is expressed as a percentage of the max_connections setting for the RDS DB instance or Aurora DB cluster used by the target group."
}

variable "max_idle_connections_percent" {
  type        = number
  default     = null
  description = "(Optional) Controls how actively the proxy closes idle database connections in the connection pool. A high value enables the proxy to leave a high percentage of idle connections open. A low value causes the proxy to close idle client connections and return the underlying database connections to the connection pool. For Aurora MySQL, it is expressed as a percentage of the max_connections setting for the RDS DB instance or Aurora DB cluster used by the target group."
}

variable "session_pinning_filters" {
  type        = list(string)
  default     = []
  description = "(Optional) Each item in the list represents a class of SQL operations that normally cause all later statements in a session using a proxy to be pinned to the same underlying database connection. Including an item in the list exempts that class of SQL operations from the pinning behavior. Currently, the only allowed value is EXCLUDE_VARIABLE_SETS."
}

variable "proxy_endpoints" {
  type        = any
  default     = {}
  description = "Map of DB proxy endpoints to create and their attributes (see `aws_db_proxy_endpoint`)"
}

variable "proxy_iam_role_description" {
  description = "Description of the monitoring role"
  type        = string
  default     = null
}

variable "proxy_iam_role_path" {
  description = "Path for the monitoring role"
  type        = string
  default     = null
}

