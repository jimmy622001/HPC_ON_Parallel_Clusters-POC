variable "vpc_id" {
  description = "ID of the VPC where EFS will be created"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs where EFS mount targets will be created"
  type        = list(string)
}

variable "security_groups" {
  description = "List of security group IDs to attach to EFS"
  type        = list(string)
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment (e.g., dev, staging, prod)"
  type        = string
}
