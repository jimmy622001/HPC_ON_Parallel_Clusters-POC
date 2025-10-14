variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "open-ondemand"
}

variable "environment" {
  description = "Environment (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
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

# db_endpoint is provided by the RDS module, not as a variable

variable "key_name" {
  description = "Name of the EC2 key pair"
  type        = string
}

variable "ondemand_instance_type" {
  description = "Instance type for Open OnDemand servers"
  type        = string
  default     = "t3.medium"
}

variable "desired_capacity" {
  description = "The number of EC2 instances that should be running in the autoscaling group"
  type        = number
  default     = 1
}

variable "min_size" {
  description = "The minimum size of the autoscaling group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "The maximum size of the autoscaling group"
  type        = number
  default     = 3
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
}

variable "zone_id" {
  description = "Route53 Zone ID for the domain"
  type        = string
}
