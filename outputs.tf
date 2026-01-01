################################################################################
# DB Subnet Group
################################################################################


################################################################################
# Cluster
################################################################################

output "cluster_arn" {
  description = "Amazon Resource Name (ARN) of cluster"
  value       = try(aws_rds_cluster.this[0].arn, null)
}

output "cluster_id" {
  description = "The RDS Cluster Identifier"
  value       = try(aws_rds_cluster.this[0].id, null)
}

output "cluster_resource_id" {
  description = "The RDS Cluster Resource ID"
  value       = try(aws_rds_cluster.this[0].cluster_resource_id, null)
}

output "cluster_members" {
  description = "List of RDS Instances that are a part of this cluster"
  value       = try(aws_rds_cluster.this[0].cluster_members, null)
}

output "cluster_endpoint" {
  description = "Writer endpoint for the cluster"
  value       = try(aws_rds_cluster.this[0].endpoint, null)
}

output "cluster_reader_endpoint" {
  description = "A read-only endpoint for the cluster, automatically load-balanced across replicas"
  value       = try(aws_rds_cluster.this[0].reader_endpoint, null)
}

output "cluster_engine_version_actual" {
  description = "The running version of the cluster database"
  value       = try(aws_rds_cluster.this[0].engine_version_actual, null)
}

# database_name is not set on `aws_rds_cluster` resource if it was not specified, so can't be used in output
output "cluster_database_name" {
  description = "Name for an automatically created database on cluster creation"
  value       = var.database_name
}

output "cluster_port" {
  description = "The database port"
  value       = try(aws_rds_cluster.this[0].port, null)
}

output "cluster_master_password" {
  description = "The database master password"
  value       = try(aws_rds_cluster.this[0].master_password, null)
  sensitive   = true
}

output "cluster_master_username" {
  description = "The database master username"
  value       = try(aws_rds_cluster.this[0].master_username, null)
  sensitive   = true
}

output "cluster_master_user_secret" {
  description = "The generated database master user secret when `manage_master_user_password` is set to `true`"
  value       = try(aws_rds_cluster.this[0].master_user_secret, null)
}

output "cluster_hosted_zone_id" {
  description = "The Route53 Hosted Zone ID of the endpoint"
  value       = try(aws_rds_cluster.this[0].hosted_zone_id, null)
}

################################################################################
# Cluster Instance(s)
################################################################################

output "cluster_instances" {
  description = "A map of cluster instances and their attributes"
  value       = aws_rds_cluster_instance.this
}

################################################################################
# Cluster Endpoint(s)
################################################################################

output "additional_cluster_endpoints" {
  description = "A map of additional cluster endpoints and their attributes"
  value       = aws_rds_cluster_endpoint.this
}

################################################################################
# Cluster IAM Roles
################################################################################

output "cluster_role_associations" {
  description = "A map of IAM roles associated with the cluster and their attributes"
  value       = aws_rds_cluster_role_association.this
}

################################################################################
# Enhanced Monitoring
################################################################################

output "enhanced_monitoring_iam_role_name" {
  description = "The name of the enhanced monitoring role"
  value       = try(aws_iam_role.rds_enhanced_monitoring[0].name, null)
}

output "enhanced_monitoring_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the enhanced monitoring role"
  value       = try(aws_iam_role.rds_enhanced_monitoring[0].arn, null)
}

output "enhanced_monitoring_iam_role_unique_id" {
  description = "Stable and unique string identifying the enhanced monitoring role"
  value       = try(aws_iam_role.rds_enhanced_monitoring[0].unique_id, null)
}

################################################################################
# Security Group
################################################################################

output "security_group_id" {
  description = "The security group ID of the cluster"
  value       = try(aws_security_group.default[0].id, null)
}

################################################################################
# Cluster Parameter Group
################################################################################

output "db_cluster_parameter_group_arn" {
  description = "The ARN of the DB cluster parameter group created"
  value       = try(aws_rds_cluster_parameter_group.this[0].arn, null)
}

output "db_cluster_parameter_group_id" {
  description = "The ID of the DB cluster parameter group created"
  value       = try(aws_rds_cluster_parameter_group.this[0].id, null)
}

################################################################################
# DB Parameter Group
################################################################################

output "db_parameter_group_arn" {
  description = "The ARN of the DB parameter group created"
  value       = try(aws_db_parameter_group.this[0].arn, null)
}

output "db_parameter_group_id" {
  description = "The ID of the DB parameter group created"
  value       = try(aws_db_parameter_group.this[0].id, null)
}

#######################################################################################################################
# RDS-PROXY: proxy output will show outputs other than empty string `""` , only when `create_db_proxy` is set to `true`
#######################################################################################################################
output "proxy_id" {
  description = "The ID of the rds proxy"
  value       = join("", try(aws_db_proxy.proxy[*].id, null))
}

output "proxy_arn" {
  description = "The Amazon Resource Name (ARN) for the proxy"
  value       = join("", try(aws_db_proxy.proxy[*].arn, null))
}

output "proxy_endpoint" {
  description = "The endpoint that you can use to connect to the proxy"
  value       = join("", try(aws_db_proxy.proxy[*].endpoint, null))
}

# Proxy Default Target Group
output "proxy_default_target_group_id" {
  description = "The ID for the default target group"
  value       = join("", try(aws_db_proxy_default_target_group.proxy[*].id, null))
}

output "proxy_default_target_group_arn" {
  description = "The Amazon Resource Name (ARN) for the default target group"
  value       = join("", try(aws_db_proxy_default_target_group.proxy[*].arn, null))
}

output "proxy_default_target_group_name" {
  description = "The name of the default target group"
  value       = join("", try(aws_db_proxy_default_target_group.proxy[*].name, null))
}

# Proxy Target
output "proxy_target_endpoint" {
  description = "Hostname for the target RDS DB Instance. Only returned for `RDS_INSTANCE` type"
  value       = join("", try(aws_db_proxy_target.proxy[*].endpoint, null))
}

output "proxy_target_id" {
  description = "Identifier of `db_proxy_name`, `target_group_name`, target type (e.g. `RDS_INSTANCE` or `TRACKED_CLUSTER`), and resource identifier separated by forward slashes (/)"
  value       = join("", try(aws_db_proxy_target.proxy[*].id, null))
}

output "proxy_target_port" {
  description = "Port for the target RDS DB Instance or Aurora DB Cluster"
  value       = join("", try(aws_db_proxy_target.proxy[*].port, null))
}

output "proxy_name" {
  description = "Identifier representing the DB Instance or DB Cluster target"
  value       = join("", try(aws_db_proxy_target.proxy[*].rds_resource_id, null))
}

output "proxy_target_target_arn" {
  description = "Amazon Resource Name (ARN) for the DB instance or DB cluster. Currently not returned by the RDS API"
  value       = join("", try(aws_db_proxy_target.proxy[*].target_arn, null))
}

output "proxy_target_tracked_cluster_id" {
  description = "DB Cluster identifier for the DB Instance target. Not returned unless manually importing an RDS_INSTANCE target that is part of a DB Cluster"
  value       = join("", try(aws_db_proxy_target.proxy[*].tracked_cluster_id, null))
}

output "proxy_target_type" {
  description = "Type of target. e.g. `RDS_INSTANCE` or `TRACKED_CLUSTER`"
  value       = join("", try(aws_db_proxy_target.proxy[*].type, null))
}

# Proxy IAM Role
output "proxy_iam_role_name" {
  description = "Name of the RDS Proxy IAM Role."
  value       = join("", aws_iam_role.proxy_iam_role[*].name)
}

output "proxy_iam_role_arn" {
  description = "Amazon Resource Name (ARN) specifying the RDS Proxy role."
  value       = join("", aws_iam_role.proxy_iam_role[*].arn)
}

output "proxy_iam_role_unique_id" {
  description = "Stable and unique string identifying the RDS Proxy role."
  value       = join("", aws_iam_role.proxy_iam_role[*].unique_id)
}

output "proxy_iam_policy_name" {
  description = "The name of the policy attached to RDS Proxy IAM Role."
  value       = join("", aws_iam_role_policy.proxy_iam_policy[*].name)
}
