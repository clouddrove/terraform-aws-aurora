################################################################################
# Cluster
################################################################################

output "cluster_arn" {
  description = "Amazon Resource Name (ARN) of cluster"
  value       = module.aurora_postgresql.cluster_arn
}

output "cluster_id" {
  description = "The RDS Cluster Identifier"
  value       = module.aurora_postgresql.cluster_id
}

output "cluster_resource_id" {
  description = "The RDS Cluster Resource ID"
  value       = module.aurora_postgresql.cluster_resource_id
}

output "cluster_members" {
  description = "List of RDS Instances that are a part of this cluster"
  value       = module.aurora_postgresql.cluster_members
}

output "cluster_endpoint" {
  description = "Writer endpoint for the cluster"
  value       = module.aurora_postgresql.cluster_endpoint
}

output "cluster_reader_endpoint" {
  description = "A read-only endpoint for the cluster, automatically load-balanced across replicas"
  value       = module.aurora_postgresql.cluster_reader_endpoint
}
