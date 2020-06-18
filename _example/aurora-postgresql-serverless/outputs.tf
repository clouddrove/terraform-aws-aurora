output "rds_cluster_id" {
  value       = module.aurora_postgresql.serverless_rds_cluster_id
  description = "The ID of the rds cluster."
}

output "rds_cluster_endpoint" {
  value       = module.aurora_postgresql.serverless_rds_cluster_endpoint
  description = "The endpoint of the rds cluster."
}

output "rds_cluster_database_name" {
  value       = module.aurora_postgresql.serverless_rds_cluster_database_name
  description = "The database name of the rds cluster."
}

output "rds_cluster_master_username" {
  value       = module.aurora_postgresql.serverless_rds_cluster_master_username
  description = "The username of the rds cluster."
}

output "rds_cluster_master_password" {
  value       = module.aurora_postgresql.serverless_rds_cluster_master_password
  description = "The password of the rds cluster."
}

output "tags" {
  value       = module.aurora_postgresql.tags
  description = "A mapping of tags to assign to the Aurora."
}