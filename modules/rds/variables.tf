variable "vpc_id" {
  description = "ID of the VPC where RDS will be created"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for RDS"
  type        = list(string)
}

variable "security_groups" {
  description = "List of security group IDs to attach to RDS"
  type        = list(string)
}

variable "db_name" {
  description = "Name of the database"
  type        = string
  default     = "slurm_accounting"
}

variable "db_username" {
  description = "Database username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "instance_class" {
  description = "Instance class for RDS instances"
  type        = string
  default     = "db.t3.medium"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment (e.g., dev, staging, prod)"
  type        = string
}
