variable "vpc_id" {
  description = "ID of the VPC where the ALB will be created"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB"
  type        = list(string)
}

variable "security_groups" {
  description = "List of security group IDs to attach to the ALB"
  type        = list(string)
}

variable "target_group_arn" {
  description = "ARN of the target group to forward traffic to"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the ALB"
  type        = string
}

variable "zone_id" {
  description = "Route53 Zone ID for the domain"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment (e.g., dev, staging, prod)"
  type        = string
}
