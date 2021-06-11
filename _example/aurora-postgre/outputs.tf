output "rds_cluster_id" {
  value       = module.postgres.rds_cluster_id
  description = "The ID of the cluster."
}

output "tags" {
  value       = module.postgres.tags
  description = "A mapping of tags to assign to the Postgres."
}
