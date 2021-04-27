#Module      : RDS AURORA CLUSTER
#Description : Terraform module which creates RDS Aurora database resources on AWS and can
#              create different type of databases. Currently it supports Postgres and MySQL.
output "rds_cluster_id" {
  value       = aws_rds_cluster.default.*.id
  description = "The ID of the cluster."
}

output "rds_cluster_endpoint" {
  value       = aws_rds_cluster.default.*.endpoint
  description = "The cluster endpoint."
}

output "rds_cluster_reader_endpoint" {
  value       = aws_rds_cluster.default.*.reader_endpoint
  description = "The cluster reader endpoint."
}

output "rds_cluster_database_name" {
  value       = var.database_name
  description = "Name for an automatically created database on cluster creation."
}

output "rds_cluster_master_password" {
  value       = aws_rds_cluster.default.*.master_password
  description = "The master password."
}

output "rds_cluster_port" {
  value       = aws_rds_cluster.default.*.port
  description = "The port of Cluster."
}

output "rds_cluster_master_username" {
  value       = aws_rds_cluster.default.*.master_username
  sensitive   = true
  description = "The master username."
}

output "rds_cluster_instance_endpoints" {
  value       = [aws_rds_cluster_instance.default.*.endpoint]
  description = "A list of all cluster instance endpoints."
}

#Module      : RDS AURORA SERVERLESS CLUSTER
#Description : Terraform module which creates RDS Aurora database resources on AWS and can
#              create different type of databases. Currently it supports Postgres and MySQL.
output "serverless_rds_cluster_id" {
  value       = aws_rds_cluster.serverless.*.id
  description = "The ID of the cluster."
}

output "serverless_rds_cluster_endpoint" {
  value       = aws_rds_cluster.serverless.*.endpoint
  description = "The cluster endpoint."
}

output "serverless_rds_cluster_reader_endpoint" {
  value       = aws_rds_cluster.serverless.*.reader_endpoint
  description = "The cluster reader endpoint."
}

output "serverless_rds_cluster_database_name" {
  value       = aws_rds_cluster.serverless.*.database_name
  description = "Name for an automatically created database on cluster creation."
}

output "serverless_rds_cluster_port" {
  value       = aws_rds_cluster.serverless.*.port
  description = "The port of Cluster."
}

output "serverless_rds_cluster_master_password" {
  value       = local.master_password
  description = "The master password."
}

output "serverless_rds_cluster_master_username" {
  sensitive   = true
  value       = aws_rds_cluster.serverless.*.master_username
  description = "The master username."
}

output "tags" {
  value       = module.labels.tags
  description = "A mapping of tags to assign to the resource."
}