################################################################################
# Cluster
################################################################################

output "cluster_arn" {
  description = "Amazon Resource Name (ARN) of cluster"
  value       = module.aurora.cluster_arn
}

output "cluster_id" {
  description = "The RDS Cluster Identifier"
  value       = module.aurora.cluster_id
}

output "cluster_resource_id" {
  description = "The RDS Cluster Resource ID"
  value       = module.aurora.cluster_resource_id
}

output "cluster_members" {
  description = "List of RDS Instances that are a part of this cluster"
  value       = module.aurora.cluster_members
}

output "cluster_endpoint" {
  description = "Writer endpoint for the cluster"
  value       = module.aurora.cluster_endpoint
}

output "cluster_reader_endpoint" {
  description = "A read-only endpoint for the cluster, automatically load-balanced across replicas"
  value       = module.aurora.cluster_reader_endpoint
}

output "cluster_master_user_secret" {
  value = module.aurora.cluster_master_user_secret[0].secret_arn
}

################################################################################
# PROXY
################################################################################

output "proxy_id" {
  description = "The ID of the rds proxy"
  value       = module.aurora.proxy_id
}

output "proxy_arn" {
  description = "The Amazon Resource Name (ARN) for the proxy"
  value       = module.aurora.proxy_arn
}

output "db_proxy_endpoints" {
  description = "Array containing the full resource object and attributes for all DB proxy endpoints created"
  value       = module.aurora.proxy_endpoint
}

output "proxy_default_target_group_id" {
  description = "The ID for the default target group"
  value       = module.aurora.proxy_default_target_group_id
}


output "proxy_default_target_group_arn" {
  description = "The Amazon Resource Name (ARN) for the default target group"
  value       = module.aurora.proxy_default_target_group_arn
}

output "proxy_default_target_group_name" {
  description = "The name of the default target group"
  value       = module.aurora.proxy_default_target_group_name
}

output "proxy_target_endpoint" {
  description = "Hostname for the target RDS DB Instance. Only returned for `RDS_INSTANCE` type"
  value       = module.aurora.proxy_target_endpoint
}

output "proxy_target_id" {
  description = "Identifier of `db_proxy_name`, `target_group_name`, target type (e.g. `RDS_INSTANCE` or `TRACKED_CLUSTER`), and resource identifier separated by forward slashes (/)"
  value       = module.aurora.proxy_target_id
}

output "proxy_target_port" {
  description = "Port for the target RDS DB Instance or Aurora DB Cluster"
  value       = module.aurora.proxy_target_port
}

output "proxy_name" {
  description = "Identifier representing the DB Instance or DB Cluster target"
  value       = module.aurora.proxy_name
}

output "proxy_target_target_arn" {
  description = "Amazon Resource Name (ARN) for the DB instance or DB cluster. Currently not returned by the RDS API"
  value       = module.aurora.proxy_target_target_arn
}

output "proxy_target_tracked_cluster_id" {
  description = "DB Cluster identifier for the DB Instance target. Not returned unless manually importing an RDS_INSTANCE target that is part of a DB Cluster"
  value       = module.aurora.proxy_target_tracked_cluster_id
}

output "proxy_target_type" {
  description = "Type of target. e.g. `RDS_INSTANCE` or `TRACKED_CLUSTER`"
  value       = module.aurora.proxy_target_type
}

output "proxy_iam_role_name" {
  description = "Name of the RDS Proxy IAM Role."
  value       = module.aurora.proxy_iam_role_name
}

output "proxy_iam_role_arn" {
  description = "Amazon Resource Name (ARN) specifying the RDS Proxy role."
  value       = module.aurora.proxy_iam_role_arn
}

output "proxy_iam_role_unique_id" {
  description = "Stable and unique string identifying the RDS Proxy role."
  value       = module.aurora.proxy_iam_role_unique_id
}

output "proxy_iam_policy_name" {
  description = "The name of the policy attached to RDS Proxy IAM Role."
  value       = module.aurora.proxy_iam_policy_name
}
