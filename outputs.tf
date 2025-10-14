output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "efs_id" {
  description = "ID of the EFS file system"
  value       = module.efs.efs_id
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = module.rds.cluster_endpoint
  sensitive   = true
}

output "ondemand_instance_ids" {
  description = "IDs of the Open OnDemand EC2 instances"
  value       = module.ondemand.instance_ids
}

output "ondemand_security_group_id" {
  description = "ID of the security group for Open OnDemand instances"
  value       = module.vpc.ondemand_security_group_id
}

output "website_url" {
  description = "URL of the Open OnDemand portal"
  value       = "https://${var.domain_name}"
}
