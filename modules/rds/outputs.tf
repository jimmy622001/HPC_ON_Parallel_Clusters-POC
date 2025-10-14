# modules/rds/outputs.tf
output "cluster_endpoint" {
  description = "The cluster endpoint"
  value       = aws_rds_cluster.main.endpoint
  depends_on = [
    aws_rds_cluster_instance.main
  ]
}

output "cluster_reader_endpoint" {
  description = "The read-only endpoint for the Aurora cluster"
  value       = aws_rds_cluster.main.reader_endpoint
  depends_on = [
    aws_rds_cluster_instance.main
  ]
}

output "cluster_id" {
  description = "The RDS Cluster Identifier"
  value       = aws_rds_cluster.main.id
}

output "cluster_resource_id" {
  description = "The RDS Cluster Resource ID"
  value       = aws_rds_cluster.main.cluster_resource_id
}

output "cluster_members" {
  description = "List of RDS Instances cluster members"
  value       = aws_rds_cluster_instance.main[*].id
}

# Primary endpoint to be used by other modules
output "db_endpoint" {
  description = "The primary database endpoint to be used by applications"
  value       = aws_rds_cluster.main.endpoint
  depends_on = [
    aws_rds_cluster_instance.main
  ]
}