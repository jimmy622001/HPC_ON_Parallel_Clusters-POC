variable "vpc_id" {
  description = "ID of the VPC where instances will be created"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for instances"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for instances"
  type        = list(string)
}

variable "security_groups" {
  description = "List of security group IDs to attach to instances"
  type        = list(string)
}

variable "key_name" {
  description = "Name of the EC2 key pair"
  type        = string
}

variable "instance_type" {
  description = "Instance type for Open OnDemand servers"
  type        = string
  default     = "t3.medium"
}

variable "efs_id" {
  description = "ID of the EFS file system for home directories"
  type        = string
}

variable "db_endpoint" {
  description = "RDS endpoint for the database"
  type        = string
}

variable "db_name" {
  description = "Name of the database"
  type        = string
  default     = "slurm_accounting"
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the Open OnDemand portal"
  type        = string
  default     = ""
  sensitive   = true
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "ood_version" {
  description = "Version of Open OnDemand to install"
  type        = string
  default     = "3.0.1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment (e.g., dev, staging, prod)"
  type        = string
}

variable "desired_capacity" {
  description = "Desired number of instances in the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances in the Auto Scaling Group"
  type        = number
  default     = 3
}

variable "min_size" {
  description = "Minimum number of instances in the Auto Scaling Group"
  type        = number
  default     = 1
}
