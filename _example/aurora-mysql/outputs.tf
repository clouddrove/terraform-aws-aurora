output "rds_cluster_id" {
  value       = module.aurora.rds_cluster_id
  description = "The ID of the cluster."
}

output "cluster_arn" {
  value       = module.aurora.cluster_arn
  description = "Amazon Resource Name (ARN) of cluster"
}

output "tags" {
  value       = module.aurora.tags
  description = "A mapping of tags to assign to the Aurora."
}

output "cluster_endpoint" {
  value       = module.aurora.rds_cluster_endpoint
  description = "Writer endpoint for the cluster"

}
