output "rds_cluster_id" {
  value       = module.aurora.rds_cluster_id
  description = "The ID of the cluster."
}

output "tags" {
  value       = module.aurora.tags
  description = "A mapping of tags to assign to the Aurora."
}
