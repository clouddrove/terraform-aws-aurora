output "rds_cluster_master_password" {
  value       = module.aurora_postgresql.serverless_rds_cluster_master_password
  description = "The password of the rds cluster."
}

output "tags" {
  value       = module.aurora_postgresql.tags
  description = "A mapping of tags to assign to the Aurora."
}
